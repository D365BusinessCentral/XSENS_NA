codeunit 50007 "Create Revenue Schedule"
{
    procedure InsertRevenueRecognitionSchedule(var SalesHeader: Record "Sales Header"; var RecSalesLinep: Record "Sales Line")
    var
        DeferralTemplate: Record "Deferral Template";
        DeferralHeader: Record "Deferral Header";
        DeferralLine: Record "Deferral Line";
        DeferralSchedule: Page "Deferral Schedule";
        DeferralUtilities: Codeunit "Deferral Utilities";
        RecRevRecSchedule: Record "Revenue Recognition Schedule";
        LineNo, i : Integer;
    begin
        if RecSalesLinep."Invoice Interval" = 0 then
            exit;
        Clear(LineNo);
        Clear(RecRevRecSchedule);
        RecRevRecSchedule.SetCurrentKey("Sales Order No.", "SO Line No.", "Line No.");
        RecRevRecSchedule.SetRange("Sales Order No.", SalesHeader."No.");
        //RecRevRecSchedule.SetRange("SO Line No.", SoLineNo);
        If RecRevRecSchedule.FindLast() then
            LineNo := RecRevRecSchedule."Line No."
        else
            LineNo := 0;


        //DeferralTemplate.Get(RecSalesLinep."Deferral Code");
        DeferralTemplate.Get(format(RecSalesLinep."Invoice Interval"));
        if DeferralHeader.Get("Deferral Document Type"::Sales.AsInteger(), '', '', RecSalesLinep."Document Type".AsInteger(), RecSalesLinep."Document No.", RecSalesLinep."Line No.") then
            DeferralHeader.Delete(true);//deleting to recreate lines with new Deferral Interval
        DeferralUtilities.CreateDeferralSchedule(format(RecSalesLinep."Invoice Interval"), "Deferral Document Type"::Sales.AsInteger(),
           '', '', RecSalesLinep."Document Type".AsInteger(), RecSalesLinep."Document No.", RecSalesLinep."Line No.", RecSalesLinep.GetDeferralAmount,
           DeferralTemplate."Calc. Method", RecSalesLinep."Shipment Date", DeferralTemplate."No. of Periods", true,
            RecSalesLinep.Description, true, RecSalesLinep."Currency Code");


        if DeferralHeader.Get("Deferral Document Type"::Sales.AsInteger(), '', '', RecSalesLinep."Document Type".AsInteger(), RecSalesLinep."Document No.", RecSalesLinep."Line No.") then begin
            if RecSalesLinep."Quantity Invoiced" <> 0 then
                exit;
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
                    RecRevRecSchedule."Contract No." := SalesHeader."No.";
                    RecRevRecSchedule."Contract Line No." := RecSalesLinep."Line No.";
                    RecRevRecSchedule."Sales Order No." := SalesHeader."No.";
                    RecRevRecSchedule."SO Line No." := RecSalesLinep."Line No.";
                    RecRevRecSchedule."Line No." := LineNo;
                    RecRevRecSchedule."Posting Date" := CalcDate('CM', DeferralLine."Posting Date");
                    RecRevRecSchedule.Amount := DeferralLine.Amount;
                    RecRevRecSchedule."Deferral Account" := DeferralTemplate."Deferral Account";
                    RecRevRecSchedule."Revenue Account" := DeferralTemplate."Revenue Account";
                    RecRevRecSchedule."Customer Name" := SalesHeader."Sell-to Customer Name";
                    RecRevRecSchedule.Country := SalesHeader."Sell-to Country/Region Code";
                    RecRevRecSchedule."Customer No." := SalesHeader."Sell-to Customer No.";
                    RecRevRecSchedule."Shortcut Dimension 1 Code" := RecSalesLinep."Shortcut Dimension 1 Code";
                    RecRevRecSchedule."Shortcut Dimension 2 Code" := RecSalesLinep."Shortcut Dimension 2 Code";
                    RecRevRecSchedule."Dimension Set Id" := RecSalesLinep."Dimension Set ID";
                    RecRevRecSchedule."Item Code" := RecSalesLinep."No.";
                    RecRevRecSchedule."Item Description" := RecSalesLinep.Description;
                    RecRevRecSchedule.Insert();
                until DeferralLine.Next() = 0;
            end;
        end;
    end;

    /* [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnBeforeValidateEvent', 'Invoice Interval', false, false)]
     local procedure OnAfterValidateEvent(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
     var
         RecRevRecSchedule: Record "Revenue Recognition Schedule";
     begin
         if Rec."Quantity Invoiced" <> 0 then
             Error('You cannot change the invoice interval for the invoiced Item')
         else
             Rec.Validate("Deferral Code", Format(Rec."Invoice Interval"));
     end;*/

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGLEntryBuffer', '', false, false)]
    local procedure OnBeforeInsertGLEntryBuffer(var BalanceCheckAddCurrAmount2: Decimal; var BalanceCheckAddCurrAmount: Decimal;
    var BalanceCheckAmount2: Decimal; var BalanceCheckAmount: Decimal; var GenJournalLine: Record "Gen. Journal Line";
    var GLEntry: Record "G/L Entry"; var NextEntryNo: Integer; var TempGLEntryBuf: Record "G/L Entry";
    var TotalAddCurrAmount: Decimal; var TotalAmount: Decimal);
    begin
        if GLEntry."Document Type" = GLEntry."Document Type"::Invoice then begin
            //Sales Information
            GLEntry."Customer No." := GenJournalLine."Customer No.";
            GLEntry."Customer Name" := GenJournalLine."Customer Name";
            TempGLEntryBuf."Posting Date" := CalcDate('CM', GLEntry."Posting Date");
            TempGLEntryBuf."Customer No." := GLEntry."Customer No.";
            TempGLEntryBuf."Customer Name" := GLEntry."Customer Name";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeader', '', false, false)]
    local procedure OnAfterCopyGenJnlLineFromSalesHeader(var GenJournalLine: Record "Gen. Journal Line";
    SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            GenJournalLine."Customer No." := SalesHeader."Sell-to Customer No.";
            GenJournalLine."Customer Name" := SalesHeader."Sell-to Customer Name";
        end;
    end;

    /* [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnBeforeActionEvent', 'Post', false, false)]
     local procedure OnBeforeActionEvent(var Rec: Record "Sales Header")
     var
         SalesLineL: Record "Sales Line";
     begin
         SalesLineL.SetRange("Document Type", Rec."Document Type");
         SalesLineL.SetRange("Document No.", Rec."No.");
         if SalesLineL.FindSet() then
             repeat
                 SalesLineL.Validate("Deferral Code", '');
                 SalesLineL.Modify();
             until SalesLineL.Next() = 0;
     end;*/
}