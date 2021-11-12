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
        }
    }
}
