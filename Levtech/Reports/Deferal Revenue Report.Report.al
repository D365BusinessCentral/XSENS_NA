report 50101 "Deferral Revenue Report"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Levtech\Reports\DeferalRevenue.rdl';

    dataset
    {
        dataitem("Revenue Recognition Schedule"; "Revenue Recognition Schedule")
        {
            RequestFilterFields = "Customer No.", "Sales invoice No.";
            DataItemTableView = sorting("Sales Order No.", "SO Line No.", "Line No.") order(ascending);

            column(Posting_Date; "Posting Date")
            {
            }
            column(Sales_invoice_No_; "Sales invoice No.")
            {
            }
            column(Sales_Order_No_; "Sales Order No.")
            {
            }
            column(SO_Line_No_; "SO Line No.")
            {
            }
            column(Posted_Invoice; 'Posted Invoice')
            {
            }
            column(Type; Type)
            {
            }
            column(Item_Description; "Item Description")
            {
            }
            column(Deferral_Account; "Deferral Account")
            {
            }
            column(Noofperiods; Noofperiods)
            {
            }
            column(AmtRecognized; AmtRecognized)
            {
            }
            column(RemainingAmtRecognized; RemainingAmtRecognized)
            {
            }
            column(Customer_No_; "Customer No.")
            {
            }
            column(Customer_Name; "Customer Name")
            {
            }
            column(CompInfo; CompInfo.Name)
            {
            }
            column(Balanceasof; Balanceasof)
            {
            }
            trigger OnPreDataItem()
            begin
                CompInfo.get();
                PrevoiusSOLineNo := 0;
                PreviousSONo := '';
                if Balanceasof <> 0D then
                    SetRange("Posting Date", Balanceasof);
            end;

            trigger OnAfterGetRecord()
            var
                SalesInvoiceLineL: Record "Sales Invoice Line";
                RevenueRecogSchedule: Record "Revenue Recognition Schedule";
                RevenueRecogSchedule1: Record "Revenue Recognition Schedule";
            begin
                Clear(Type);
                Clear(Noofperiods);
                SalesInvoiceLineL.SetRange("Document No.", "Revenue Recognition Schedule"."Sales invoice No.");
                SalesInvoiceLineL.SetRange("Line No.", "Revenue Recognition Schedule"."SO Line No.");
                if SalesInvoiceLineL.FindFirst() then begin
                    Type := format(SalesInvoiceLineL.Type);
                    if SalesInvoiceLineL."Invoice Interval" <> 0 then
                        Noofperiods := FORMAT(SalesInvoiceLineL."Invoice Interval"); //"Deferral Code";
                end;

                // if (PrevoiusSOLineNo = "Revenue Recognition Schedule"."SO Line No.") and (PreviousSONo = "Revenue Recognition Schedule"."Sales Order No.") then
                //    CurrReport.Skip();
                if not CheckList.Contains(FORMAT("Revenue Recognition Schedule"."SO Line No.") + FORMAT("Revenue Recognition Schedule"."Sales Order No.")) then begin
                    CheckList.Add(FORMAT("Revenue Recognition Schedule"."SO Line No.") + FORMAT("Revenue Recognition Schedule"."Sales Order No."));
                end else
                    CurrReport.Skip();

                Clear(AmtRecognized);
                Clear(RevenueRecogSchedule);
                RevenueRecogSchedule.SetRange("Sales Order No.", "Revenue Recognition Schedule"."Sales Order No.");
                RevenueRecogSchedule.SetRange("Sales invoice No.", "Revenue Recognition Schedule"."Sales invoice No.");
                RevenueRecogSchedule.SetRange("SO Line No.", "Revenue Recognition Schedule"."SO Line No.");
                RevenueRecogSchedule.SetRange(Posted, true);
                if RevenueRecogSchedule.FindSet() then begin
                    repeat
                        // PreviousSONo := RevenueRecogSchedule."Sales Order No.";
                        // PrevoiusSOLineNo := RevenueRecogSchedule."SO Line No.";
                        AmtRecognized := AmtRecognized + RevenueRecogSchedule.Amount;
                    until RevenueRecogSchedule.Next() = 0;
                end;
                Clear(RevenueRecogSchedule1);
                Clear(RemainingAmtRecognized);
                RevenueRecogSchedule1.SetRange("Sales Order No.", "Revenue Recognition Schedule"."Sales Order No.");
                RevenueRecogSchedule1.SetRange("SO Line No.", "Revenue Recognition Schedule"."SO Line No.");
                RevenueRecogSchedule1.SetRange(Posted, false);
                if RevenueRecogSchedule1.FindSet() then begin
                    repeat
                        // PreviousSONo := RevenueRecogSchedule1."Sales Order No.";
                        // PrevoiusSOLineNo := RevenueRecogSchedule1."SO Line No.";
                        RemainingAmtRecognized := RemainingAmtRecognized + RevenueRecogSchedule1.Amount;
                    until RevenueRecogSchedule1.Next() = 0;
                end;
            end;
        }
    }
    requestpage
    {
        // SaveValues = true;

        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(Balanceasof; Balanceasof)
                    {
                        ApplicationArea = All;
                        Caption = 'Balance as of:';
                    }
                }
            }
        }
    }
    var
        AmtRecognized: Decimal;
        RemainingAmtRecognized: Decimal;
        Type: Text;
        Noofperiods: Code[10];
        CompInfo: Record "Company Information";
        Balanceasof: Date;
        PrevoiusSOLineNo: Integer;
        PreviousSONo: Code[20];
        CheckList: List of [Text];
}
