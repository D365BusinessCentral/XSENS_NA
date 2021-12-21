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
            RequestFilterFields = "Posting Date", "Sales invoice No.";
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
                GenJnlLine.Validate("Posting Date", CalcDate('CM', "Revenue Recognition Schedule"."Posting Date"));
                GenJnlLine.Validate("Document No.", NoSeriesMgmt.GetNextNo(SalesSetup."Revenue Recognition Nos.", WorkDate(), true));
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
                GenJnlLine."Item Code" := "Revenue Recognition Schedule"."Item Code";
                GenJnlLine."Item Description" := "Revenue Recognition Schedule"."Item Description";
                //Need to remove from Live
                GenJnlLine.Validate("Reason Code", "Revenue Recognition Schedule"."Reason Code");
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
                GenJnlManagement: Codeunit GenJnlManagement;
                GenJnlBatch: Record "Gen. Journal Batch";
            begin
                if IsPost then begin
                    Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJnlLine);
                end else begin
                    Commit();
                    Clear(GenJnlBatch);
                    GenJnlBatch.SetRange("Journal Template Name", SalesSetup."Revenue Rec. Template Name");
                    GenJnlBatch.SetRange(Name, SalesSetup."Revenue Rec. Batch Name");
                    if GenJnlBatch.FindFirst() then begin
                        GenJnlManagement.TemplateSelectionFromBatch(GenJnlBatch);
                    end;
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
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

    trigger OnInitReport()
    var
        myInt: Integer;
    begin
        IsPost := true;
    end;


    local procedure GetLastLineNumber(): Integer

    begin
        SalesSetup.GET;
        SalesSetup.TestField("Revenue Rec. Template Name");
        SalesSetup.TestField("Revenue Rec. Batch Name");
        SalesSetup.TestField("Revenue Recognition Nos.");
        Clear(GenJnlLine);
        GenJnlLine.SetRange("Journal Template Name", SalesSetup."Revenue Rec. Template Name");
        GenJnlLine.SetRange("Journal Batch Name", SalesSetup."Revenue Rec. Batch Name");
        if GenJnlLine.FindSet() then
            GenJnlLine.DeleteAll(true);
        // clear(GenJnlLine);
        // GenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Line No.");
        // GenJnlLine.SetRange("Journal Template Name", SalesSetup."Revenue Rec. Template Name");
        // GenJnlLine.SetRange("Journal Batch Name", SalesSetup."Revenue Rec. Batch Name");
        // if GenJnlLine.FindLast() then
        //     exit(GenJnlLine."Line No.")
        // else
        exit(0);
    end;

    var
        IsPost: Boolean;
        GenJnlLine: Record "Gen. Journal Line";
        SalesSetup: Record "Sales & Receivables Setup";
        LineNo, FromLineNumber : Integer;
}