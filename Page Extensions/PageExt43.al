pageextension 50007 "Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addlast(content)
        {
            group("Chinese Localization")
            {
                Caption = 'Chinese Localization';
                field("VAT Customer Name"; Rec."VAT Customer Name")
                {
                    Importance = Promoted;
                    ApplicationArea = All;
                }
                field("VAT Address & Telephone"; Rec."VAT Address & Telephone")
                {
                    ApplicationArea = All;
                }
                field("VAT Bank Name & Account"; Rec."VAT Bank Name & Account")
                {
                    ApplicationArea = All;
                }
                field("VAT Invoice Mail Address"; Rec."VAT Invoice Mail Address")
                {
                    ApplicationArea = All;
                }
                field("VAT Contact Information"; Rec."VAT Contact Information")
                {
                    ApplicationArea = All;
                }
            }
        }
        addlast(Control205)
        {
            field("Bill-to Email"; Rec."Bill-to Email")
            {
                ApplicationArea = All;
            }
        }
    }
}