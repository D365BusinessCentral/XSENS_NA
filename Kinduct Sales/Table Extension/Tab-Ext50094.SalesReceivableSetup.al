tableextension 50094 "Sales & Receivable Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50000; "Revenue Rec. Template Name"; code[10])
        {
            Caption = 'Revenue Rec. Template Name';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Template";
        }
        field(50001; "Revenue Rec. Batch Name"; Code[10])
        {
            Caption = 'Revenue Rec. Batch Name';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Revenue Rec. Template Name"));
        }
        field(50002; "Revenue Recognition Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }

    }
}
