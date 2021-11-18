pageextension 50030 GeneralJnl extends "General Journal"
{
    layout

    {
        /*addlast(Control1)
        {
            field("Credit Card Payee No."; Rec."Credit Card Payee No.")
            {
                ApplicationArea = All;
                Caption = 'Credit Card Payee No.';
            }
            field("Credit Card Payee Name"; Rec."Credit Card Payee Name")
            {
                ApplicationArea = All;
                Caption = 'Credit Card Payee Name';
            }
        }*/
        addlast(Control1)
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
        }

    }
}
