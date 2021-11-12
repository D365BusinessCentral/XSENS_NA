pageextension 50014 "Posted Sales Invoice" extends "Posted Sales Invoice"
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
        addafter("Shipment Method Code")
        {
            field("Shipment Method Description"; Rec."Shipment Method Description")
            {
                ApplicationArea = All;
            }
        }
        addlast("Bill-to")
        {
            field("Bill-to Email"; Rec."Bill-to Email")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addfirst(processing)
        {
            action("Revenue Schedule")
            {
                ApplicationArea = All;
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    RecRevRecSchedule: Record "Revenue Recognition Schedule";
                    PageRevRecog: Page "Revenue Recognition Schedule";
                begin
                    //Rec.TestField("Created From Contract");
                    Clear(RecRevRecSchedule);
                    RecRevRecSchedule.SetCurrentKey("Sales invoice No.", "SO Line No.", "Line No.");
                    RecRevRecSchedule.SetRange("Sales invoice No.", Rec."No.");
                    If RecRevRecSchedule.FindSet() then begin
                        Clear(PageRevRecog);
                        PageRevRecog.SetTableView(RecRevRecSchedule);
                        PageRevRecog.Run();
                    end;
                end;
            }
        }
    }
}
