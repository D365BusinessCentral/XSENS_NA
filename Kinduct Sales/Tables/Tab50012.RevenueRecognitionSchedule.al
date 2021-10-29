table 50012 "Revenue Recognition Schedule"
{
    Caption = 'Revenue Recognition Schedule';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            DataClassification = ToBeClassified;
        }
        field(2; "SO Line No."; Integer)
        {
            Caption = 'SO Line No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Sales invoice No."; Code[20])
        {
            Caption = 'Sales invoice No.';
            DataClassification = ToBeClassified;
        }
        field(4; "Sales Invoice Date"; Date)
        {
            Caption = 'Sales Invoice Date';
            DataClassification = ToBeClassified;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = ToBeClassified;
        }
        field(6; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = ToBeClassified;
        }
        field(7; "Deferral Account"; Code[20])
        {
            Caption = 'Deferral Account';
            DataClassification = ToBeClassified;
        }
        field(8; "Revenue Account"; Code[20])
        {
            Caption = 'Revenue Account';
            DataClassification = ToBeClassified;
        }
        field(9; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(10; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = ToBeClassified;
        }
        field(12; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Contract No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Contract Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Sales Order No.", "SO Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

}
