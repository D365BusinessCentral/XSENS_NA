report 50022 "Recognize Revenue"
{
    ProcessingOnly = true;
    UseRequestPage = true;
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem("Revenue Recognition Schedule"; "Revenue Recognition Schedule")
        {
            DataItemTableView = sorting("Sales Order No.", "SO Line No.", "Line No.") order(ascending) where(Posted = const(false), "Sales invoice No." = filter(<> ''), "Document No." = filter(= ''));
            RequestFilterFields = "Posting Date";
            trigger OnAfterGetRecord()
            var
                NoSeriesMgmt: Codeunit NoSeriesManagement;
            begin
                LineNo += 10000;
                GenJnlLine.Init();
                GenJnlLine."System-Created Entry" := true;
                GenJnlLine.Validate("Journal Template Name", SalesSetup."Revenue Rec. Template Name");
                GenJnlLine.Validate("Journal Batch Name", SalesSetup."Revenue Rec. Batch Name");
                GenJnlLine.Validate("Line No.", LineNo);
                GenJnlLine.Validate("Posting Date", "Revenue Recognition Schedule"."Posting Date");
                GenJnlLine.Validate("Document No.", NoSeriesMgmt.GetNextNo(SalesSetup."Revenue Recognition Nos.", WorkDate(), IsPost));
                GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Account No.", "Revenue Recognition Schedule"."Deferral Account");
                GenJnlLine.Validate("Revenue SO No.", "Revenue Recognition Schedule"."Sales Order No.");
                GenJnlLine.Validate("Revenue SO Line No.", "Revenue Recognition Schedule"."SO Line No.");
                GenJnlLine.Validate("Revenue Sales Invoice No.", "Revenue Recognition Schedule"."Sales invoice No.");
                GenJnlLine.Validate("Revenue Sales Invoice Date", "Revenue Recognition Schedule"."Sales Invoice Date");
                GenJnlLine.Validate("Revenue Line No.", "Revenue Recognition Schedule"."Line No.");
                GenJnlLine.Validate("Contract No.", "Revenue Recognition Schedule"."Contract No.");
                GenJnlLine.Validate("Contract Line No.", "Revenue Recognition Schedule"."Contract Line No.");
                GenJnlLine.Validate(Amount, "Revenue Recognition Schedule".Amount);
                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                GenJnlLine.Validate("Bal. Account No.", "Revenue Recognition Schedule"."Revenue Account");
                GenJnlLine.Validate("Shortcut Dimension 1 Code", "Revenue Recognition Schedule"."Shortcut Dimension 1 Code");
                GenJnlLine.Validate("Shortcut Dimension 2 Code", "Revenue Recognition Schedule"."Shortcut Dimension 2 Code");
                GenJnlLine.Validate("Dimension Set ID", "Revenue Recognition Schedule"."Dimension Set Id");
                GenJnlLine."Customer No." := "Revenue Recognition Schedule"."Customer No.";
                GenJnlLine."Customer Name" := "Revenue Recognition Schedule"."Customer Name";
                GenJnlLine."Country/Region Code" := "Revenue Recognition Schedule".Country;
                GenJnlLine.Insert(true);
            end;

            trigger OnPreDataItem()
            begin
                LineNo := GetLastLineNumber();
                FromLineNumber := LineNo;
            end;

            trigger OnPostDataItem()
            var
                PageGenJnl: Page "General Journal";
                RecGenJournal: Record "Gen. Journal Line";
                RevenueRecognitionScheduleL: Record "Revenue Recognition Schedule";
            begin
                if IsPost then begin
                    Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJnlLine);
                    RevenueRecognitionScheduleL.SetCurrentKey("Sales Order No.", "SO Line No.");
                    RevenueRecognitionScheduleL.SetRange("Sales Order No.", "Sales Order No.");
                    RevenueRecognitionScheduleL.SetRange("SO Line No.", "SO Line No.");
                    RevenueRecognitionScheduleL.SetFilter("Sales invoice No.", '<>%1', '');
                    RevenueRecognitionScheduleL.SetRange(Posted, false);
                    if RevenueRecognitionScheduleL.FindSet() then
                        repeat
                            RevenueRecognitionScheduleL.Posted := true;
                            RevenueRecognitionScheduleL.Modify();
                        until RevenueRecognitionScheduleL.Next() = 0;
                end else begin
                    Clear(PageGenJnl);
                    PageGenJnl.SetTableView(GenJnlLine);
                    if PageGenJnl.RunModal() in [Action::OK, Action::Cancel, Action::LookupOK] then begin
                        Clear(RecGenJournal);
                        RecGenJournal.SetRange("Journal Template Name", SalesSetup."Revenue Rec. Template Name");
                        RecGenJournal.SetRange("Journal Batch Name", SalesSetup."Revenue Rec. Batch Name");
                        RecGenJournal.SetFilter("Line No.", '>%1', FromLineNumber);
                        if RecGenJournal.FindSet() then
                            RecGenJournal.DeleteAll(true);
                    end
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(IsPost; IsPost)
                    {
                        ApplicationArea = All;
                        Caption = 'Post';
                    }
                }
            }
        }
    }


    local procedure GetLastLineNumber(): Integer
    begin
        SalesSetup.GET;
        SalesSetup.TestField("Revenue Rec. Template Name");
        SalesSetup.TestField("Revenue Rec. Batch Name");
        SalesSetup.TestField("Revenue Recognition Nos.");
        clear(GenJnlLine);
        GenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Line No.");
        GenJnlLine.SetRange("Journal Template Name", SalesSetup."Revenue Rec. Template Name");
        GenJnlLine.SetRange("Journal Batch Name", SalesSetup."Revenue Rec. Batch Name");
        if GenJnlLine.FindLast() then
            exit(GenJnlLine."Line No.")
        else
            exit(0);
    end;

    var
        IsPost: Boolean;
        GenJnlLine: Record "Gen. Journal Line";
        SalesSetup: Record "Sales & Receivables Setup";
        LineNo, FromLineNumber : Integer;
}