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
        RecSalesLinep.TestField("Contract Start Date");
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
           '', '', RecSalesLinep."Document Type".AsInteger(), RecSalesLinep."Document No.", RecSalesLinep."Line No.", RecSalesLinep.CalcLineAmount(),//Need to remove from Live //RecSalesLinep.GetDeferralAmount,//Changed it to line amount as they request to use line amount exc VAT-13JAN2021
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
                    if RecSalesLinep."Invoice Interval" = 1 then
                        RecRevRecSchedule.Amount := RecSalesLinep.CalcLineAmount() //Need to remove from live//RecSalesLinep."Amount Including VAT"//Changed it to line amount as they request to use line amount exc VAT-13JAN2021
                    else
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
                    //Need to remove from Live
                    RecRevRecSchedule."Reason Code" := SalesHeader."Reason Code";
                    RecRevRecSchedule.Insert();
                until (RecSalesLinep."Invoice Interval" = 1) OR (DeferralLine.Next() = 0);
            end;
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