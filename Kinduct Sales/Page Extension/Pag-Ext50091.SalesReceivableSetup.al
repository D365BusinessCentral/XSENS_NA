pageextension 50091 "Sales&ReceivableSetup" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(content)
        {
            group("Revenue Recognition Schedule")
            {
                field("Revenue Rec. Template Name"; Rec."Revenue Rec. Template Name")
                {
                    ApplicationArea = All;
                }
                field("Revenue Rec. Batch Name"; Rec."Revenue Rec. Batch Name")
                {
                    ApplicationArea = All;
                }
                field("Revenue Recognition Nos."; Rec."Revenue Recognition Nos.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
