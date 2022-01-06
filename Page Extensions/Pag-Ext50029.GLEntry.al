pageextension 50029 GLEntry extends "General Ledger Entries"
{
    layout

    {
        addlast(Control1)
        {
            /*field("Vendor No."; Rec."Credit Card Payee No.")
            {
                ApplicationArea = All;
                Caption = 'Vendor No.';
            }
            field("Vendor Name"; Rec."Credit Card Payee Name")
            {
                ApplicationArea = All;
                Caption = 'Vendor Name';
            }*/
        }
        addafter("G/L Account Name")
        {
            field("Customer No."; Rec."Customer No.")
            {
                ApplicationArea = All;
            }
            field("Customer Name"; Rec."Customer Name")
            {
                ApplicationArea = All;
            }
            field("Item Code"; Rec."Item Code")
            {
                ApplicationArea = All;
            }
            field("Item Description"; Rec."Item Description")
            {
                ApplicationArea = All;
            }
            field("Country/Region Code"; Rec."Country/Region Code")
            {
                ApplicationArea = All;
            }
        }
        addlast(Control1)
        {
            field("Revenue SO No."; Rec."Revenue SO No.")
            {
                ApplicationArea = All;
            }
            field("Revenue SO Line No."; Rec."Revenue SO Line No.")
            {
                ToolTip = 'Specifies the value of the Revenue SO Line No. field.';
                ApplicationArea = All;
            }
            field("Revenue Line No."; Rec."Revenue Line No.")
            {
                ToolTip = 'Specifies the value of the Revenue Line No. field.';
                ApplicationArea = All;
            }
            field("Revenue Sales Invoice No."; Rec."Revenue Sales Invoice No.")
            {
                ToolTip = 'Specifies the value of the Revenue Sales Invoice No. field.';
                ApplicationArea = All;
            }
            field("Revenue Sales Invoice Date"; Rec."Revenue Sales Invoice Date")
            {
                ToolTip = 'Specifies the value of the Revenue Sales Invoice Date field.';
                ApplicationArea = All;
            }
            field("Transaction No."; Rec."Transaction No.")
            {
                ApplicationArea = All;
            }
            field("Business Unit Code"; Rec."Business Unit Code")
            {
                ApplicationArea = All;
            }
        }
        modify("Source Type")
        {
            Visible = true;
        }
        modify("Source No.")
        {
            Visible = true;
        }
    }
}
