table 50006 "Contract Information"
{
    Caption = 'Contract Information';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = ToBeClassified;
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = ToBeClassified;
            TableRelation = Customer;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(5; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;
            TableRelation = Item;
            trigger OnValidate()
            var
                RecItem: Record Item;
            begin
                if RecItem.GET("Item No.") then
                    "Item Description" := RecItem.Description
                else
                    "Item Description" := '';
            end;
        }
        field(6; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = ToBeClassified;
        }
        field(7; "Contract Length"; Integer)
        {
            Caption = 'Contract Length';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                CalculateAmount();
            end;
        }
        field(8; "Contract Start Date"; Date)
        {
            Caption = 'Contract Start Date';
            DataClassification = ToBeClassified;
        }
        field(9; "Invoice Interval"; Integer)
        {
            Caption = 'Invoice Interval';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                CalculateAmount();
            end;
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                CalculateAmount();
            end;
        }
        field(11; Currency; Code[10])
        {
            Caption = 'Currency';
            DataClassification = ToBeClassified;
            TableRelation = Currency;
        }
        field(12; "Unit Price Per Invoice Period"; Decimal)
        {
            Caption = 'Unit Price Per Invoice Period';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                CalculateAmount();
            end;
        }
        field(13; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = ToBeClassified;
        }
        field(14; "Status"; Option)
        {
            OptionMembers = "Ready To Sync",Synced,Error,Posted;
        }
        field(15; "Error Remarks"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Sales Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Contract No.", "Line No.")
        {
            Clustered = true;
        }
    }
    local procedure CalculateAmount()
    begin
        if "Invoice Interval" <> 0 then begin
            Amount := ("Contract Length" / "Invoice Interval") * Quantity * "Unit Price Per Invoice Period"
        end else
            Amount := 0;
    end;
}
