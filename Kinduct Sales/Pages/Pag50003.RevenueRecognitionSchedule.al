page 50003 "Revenue Recognition Schedule"
{

    Caption = 'Revenue Recognition Schedule';
    PageType = List;
    SourceTable = "Revenue Recognition Schedule";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Sales Order No."; Rec."Sales Order No.")
                {
                    ToolTip = 'Specifies the value of the Sales Order No. field.';
                    ApplicationArea = All;
                }
                field("SO Line No."; Rec."SO Line No.")
                {
                    ToolTip = 'Specifies the value of the SO Line No. field.';
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    ApplicationArea = All;
                }
                field("Sales invoice No."; Rec."Sales invoice No.")
                {
                    ToolTip = 'Specifies the value of the Sales invoice No. field.';
                    ApplicationArea = All;
                }
                field("Sales Invoice Date"; Rec."Sales Invoice Date")
                {
                    ToolTip = 'Specifies the value of the Sales Invoice Date field.';
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.';
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = All;
                }
                field("Deferral Account"; Rec."Deferral Account")
                {
                    ToolTip = 'Specifies the value of the Deferral Account field.';
                    ApplicationArea = All;
                }
                field("Revenue Account"; Rec."Revenue Account")
                {
                    ToolTip = 'Specifies the value of the Revenue Account field.';
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the value of the Document Date field.';
                    ApplicationArea = All;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item Code"; Rec."Item Code")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                }
                field(Country; Rec.Country)
                {
                    ToolTip = 'Specifies the value of the Customer Country field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                //Need to remove from Live
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
