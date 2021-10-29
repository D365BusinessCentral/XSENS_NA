pageextension 50090 "Deferral Template" extends "Deferral Template Card"
{
    layout
    {
        addafter("Deferral Account")
        {
            field("Revenue Account"; Rec."Revenue Account")
            {
                ApplicationArea = All;
            }
        }
    }
}
