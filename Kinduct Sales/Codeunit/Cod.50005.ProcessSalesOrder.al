codeunit 50005 "Process Contract Information"
{
    TableNo = "Contract Information";

    trigger OnRun()
    var
        RecSalesHeader: Record "Sales Header";
        RecSalesperson: Record "Salesperson/Purchaser";
        SalesReceivableSetup: Record "Sales & Receivables Setup";
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        RecSalesLine: Record "Sales Line";
        RecLocation: Record Location;
        LineNo, TotalLines, i : Integer;
    begin
        SalesReceivableSetup.GET;
        Rec.TestField("Contract No.");
        Rec.TestField("Customer No.");
        Clear(RecSalesHeader);
        RecSalesHeader.SetRange("Document Type", RecSalesHeader."Document Type"::Order);
        RecSalesHeader.SetRange("Contract No.", Rec."Contract No.");
        RecSalesHeader.SetRange("Contract Line No.", Rec."Line No.");
        if RecSalesHeader.FindFirst() then
            Error('Record already exists in Sales Header Contract No. %1, Line No.%2', Rec."Contract No.", Rec."Line No.");
        //Creating Sales Order
        Clear(RecSalesHeader);
        RecSalesHeader.Init();
        RecSalesHeader.SetHideValidationDialog(true);
        RecSalesHeader.Validate("Document Type", RecSalesHeader."Document Type"::Order);
        RecSalesHeader.Validate("No.", NoSeriesMgmt.GetNextNo(SalesReceivableSetup."Order Nos.", WorkDate(), true));
        RecSalesHeader.Validate("Sell-to Customer No.", Rec."Customer No.");
        RecSalesHeader.Validate("Order Date", Rec."Date");
        RecSalesHeader.Validate("Posting Date", Rec."Date");
        RecSalesHeader."Created From Contract" := true;
        RecSalesHeader.Validate("Contract Line No.", Rec."Line No.");
        RecSalesHeader.Validate("Contract No.", Rec."Contract No.");
        RecSalesHeader.Insert(true);
        ShipmentDate := Rec.Date;
        Rec."Sales Order No." := RecSalesHeader."No.";
        //Inserting Lines

        Clear(LineNo);
        Clear(RecSalesLine);
        RecSalesLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        RecSalesLine.SetRange("Document Type", RecSalesLine."Document Type"::Order);
        RecSalesLine.SetRange("Document No.", RecSalesHeader."No.");
        If RecSalesLine.FindLast() then
            LineNo := RecSalesLine."Line No."
        else
            LineNo := 0;
        TotalLines := Rec."Contract Length" / Rec."Invoice Interval";

        for i := 1 to TotalLines do begin
            LineNo += 10000;
            Clear(RecSalesLine);
            RecSalesLine.Init();
            RecSalesLine.SetHideValidationDialog(true);
            RecSalesLine.SetHasBeenShown();
            RecSalesLine.Validate("Document Type", RecSalesLine."Document Type"::Order);
            RecSalesLine.Validate("Document No.", RecSalesHeader."No.");
            RecSalesLine.Validate("Line No.", LineNo);
            RecSalesLine.Validate(Type, RecSalesLine.Type::Item);
            RecSalesLine.Validate("No.", Rec."Item No.");
            RecSalesLine.Validate(Quantity, Rec.Quantity);
            RecSalesLine.Validate("Unit Price", Rec."Unit Price Per Invoice Period");
            RecSalesLine.Validate("Shipment Date", ShipmentDate);
            //RecSalesLine.Validate("Posting Date", ShipmentDate);
            RecSalesLine.Validate("Deferral Code", FORMAT(Rec."Invoice Interval"));
            RecSalesLine.Insert(true);
            InsertRevenueRecognitionSchedule(Rec, (Rec.Quantity * Rec."Unit Price Per Invoice Period") / Rec."Invoice Interval", ShipmentDate, LineNo, RecSalesLine);
            ShipmentDate := CalcDate(FORMAT(Rec."Invoice Interval") + 'M', ShipmentDate);
        end;

        Rec.Modify();
    end;

    local procedure InsertRevenueRecognitionSchedule(var RecContractInfo: record "Contract Information"; Amount: Decimal; ShipmentDatep: date; SoLineNo: Integer; var RecSalesLinep: Record "Sales Line")
    var
        DeferralTemplate: Record "Deferral Template";
        DeferralHeader: Record "Deferral Header";
        DeferralLine: Record "Deferral Line";
        DeferralSchedule: Page "Deferral Schedule";
        DeferralUtilities: Codeunit "Deferral Utilities";

        RecRevRecSchedule: Record "Revenue Recognition Schedule";
        LineNo, i : Integer;
    begin
        Clear(LineNo);
        Clear(RecRevRecSchedule);
        RecRevRecSchedule.SetCurrentKey("Sales Order No.", "SO Line No.", "Line No.");
        RecRevRecSchedule.SetRange("Sales Order No.", RecContractInfo."Sales Order No.");
        //RecRevRecSchedule.SetRange("SO Line No.", SoLineNo);
        If RecRevRecSchedule.FindLast() then
            LineNo := RecRevRecSchedule."Line No."
        else
            LineNo := 0;
        // for i := 1 to RecContractInfo."Invoice Interval" do begin

        // end;

        DeferralTemplate.Get(RecSalesLinep."Deferral Code");
        if not DeferralHeader.Get("Deferral Document Type"::Sales.AsInteger(), '', '', RecSalesLinep."Document Type".AsInteger(), RecSalesLinep."Document No.", RecSalesLinep."Line No.") then
            DeferralUtilities.CreateDeferralSchedule(RecSalesLinep."Deferral Code", "Deferral Document Type"::Sales.AsInteger(),
               '', '', RecSalesLinep."Document Type".AsInteger(), RecSalesLinep."Document No.", RecSalesLinep."Line No.", RecSalesLinep.GetDeferralAmount,
               DeferralTemplate."Calc. Method", ShipmentDatep, DeferralTemplate."No. of Periods", true,
                RecSalesLinep.Description, true, RecSalesLinep."Currency Code");


        if DeferralHeader.Get("Deferral Document Type"::Sales.AsInteger(), '', '', RecSalesLinep."Document Type".AsInteger(), RecSalesLinep."Document No.", RecSalesLinep."Line No.") then begin
            Clear(DeferralLine);
            DeferralLine.SetRange("Deferral Doc. Type", DeferralHeader."Deferral Doc. Type");
            DeferralLine.SetRange("Gen. Jnl. Batch Name", '');
            DeferralLine.SetRange("Gen. Jnl. Template Name", '');
            DeferralLine.SetRange("Document Type", DeferralHeader."Document Type");
            DeferralLine.SetRange("Document No.", DeferralHeader."Document No.");
            DeferralLine.SetRange("Line No.", DeferralHeader."Line No.");
            if DeferralLine.FindSet() then begin
                repeat
                    LineNo += 10000;
                    RecRevRecSchedule.Init();
                    RecRevRecSchedule."Contract No." := RecContractInfo."Contract No.";
                    RecRevRecSchedule."Contract Line No." := RecContractInfo."Line No.";
                    RecRevRecSchedule."Sales Order No." := RecContractInfo."Sales Order No.";
                    RecRevRecSchedule."SO Line No." := SoLineNo;
                    RecRevRecSchedule."Line No." := LineNo;
                    RecRevRecSchedule."Posting Date" := CalcDate('CM', DeferralLine."Posting Date");
                    RecRevRecSchedule.Amount := DeferralLine.Amount;
                    RecRevRecSchedule."Deferral Account" := DeferralTemplate."Deferral Account";
                    RecRevRecSchedule."Revenue Account" := DeferralTemplate."Revenue Account";
                    RecRevRecSchedule.Insert();
                until DeferralLine.Next() = 0;
            end;
        end;
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesLine', '', false, false)]
    local procedure OnAfterPostSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var SalesInvLine: Record "Sales Invoice Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var xSalesLine: Record "Sales Line");
    var
        RecRevRecSchedule: Record "Revenue Recognition Schedule";
    begin
        if not (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then exit;
        if SalesLine."Qty. to Invoice" = 0 then
            exit;
        Clear(RecRevRecSchedule);
        RecRevRecSchedule.SetCurrentKey("Sales Order No.", "SO Line No.", "Line No.");
        RecRevRecSchedule.SetRange("Sales Order No.", SalesHeader."No.");
        RecRevRecSchedule.SetRange("SO Line No.", SalesLine."Line No.");
        If RecRevRecSchedule.FindSet() then begin
            repeat
                RecRevRecSchedule."Sales invoice No." := SalesInvLine."Document No.";
                RecRevRecSchedule."Sales Invoice Date" := SalesInvLine."Posting Date";
                if SalesHeader."Currency Factor" <> 0 then
                    RecRevRecSchedule.Amount := RecRevRecSchedule.Amount / SalesHeader."Currency Factor";
                RecRevRecSchedule.Modify();
            until RecRevRecSchedule.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', false, false)]
    local procedure OnAfterInitGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; Amount: Decimal; AddCurrAmount: Decimal; UseAddCurrAmount: Boolean; var CurrencyFactor: Decimal);
    var
        RecRevSchedule: Record "Revenue Recognition Schedule";
        RecCompany: Record "Company Information";
    begin
        RecCompany.GET;
        if not RecCompany."Kinduct Deferral" then exit;
        GLEntry."Revenue SO No." := GenJournalLine."Revenue SO No.";
        GLEntry."Revenue SO Line No." := GenJournalLine."Revenue SO Line No.";
        GLEntry."Revenue Line No." := GenJournalLine."Revenue Line No.";
        GLEntry."Contract No." := GenJournalLine."Contract No.";
        GLEntry."Revenue Sales Invoice No." := GenJournalLine."Revenue Sales Invoice No.";
        GLEntry."Revenue Sales Invoice Date" := GenJournalLine."Revenue Sales Invoice Date";
        GLEntry."Contract Line No." := GenJournalLine."Contract Line No.";
        GLEntry."Customer No." := GenJournalLine."Customer No.";
        GLEntry."Customer Name" := GenJournalLine."Customer Name";
        GLEntry."Global Dimension 1 Code" := GenJournalLine."Shortcut Dimension 1 Code";
        GLEntry."Global Dimension 2 Code" := GenJournalLine."Shortcut Dimension 2 Code";
        GLEntry."Dimension Set ID" := GenJournalLine."Dimension Set ID";
        GLEntry."Country/Region Code" := GenJournalLine."Country/Region Code";
        GLEntry."Item Code" := GenJournalLine."Item Code";
        GLEntry."Item Description" := GenJournalLine."Item Description";
        if GenJournalLine."Revenue SO No." <> '' then begin
            Clear(RecRevSchedule);
            RecRevSchedule.SetRange("Sales Order No.", GenJournalLine."Revenue SO No.");
            RecRevSchedule.SetRange("SO Line No.", GenJournalLine."Revenue SO Line No.");
            RecRevSchedule.SetRange("Sales invoice No.", GenJournalLine."Revenue Sales Invoice No.");
            RecRevSchedule.SetRange("Line No.", GenJournalLine."Revenue Line No.");
            if RecRevSchedule.FindFirst() then begin
                RecRevSchedule."Document No." := GLEntry."Document No.";
                RecRevSchedule."Document Date" := GLEntry."Posting Date";
                RecRevSchedule.Posted := true;
                RecRevSchedule.Modify();
            end;
        end
    end;

    var
        ShipmentDate: Date;
}