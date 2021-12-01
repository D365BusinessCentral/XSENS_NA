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
            Caption = 'Posted Sales invoice No.';
            DataClassification = ToBeClassified;
        }
        field(4; "Sales Invoice Date"; Date)
        {
            Caption = 'Posted Sales Invoice Date';
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
        field(16; "Customer Name"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Country"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Dimension Set Id"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
        }
        field(21; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));
        }
        field(22; "Item Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Item Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        //Need to remove from Live
        field(24; "Reason Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Reason Code";
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
