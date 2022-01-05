page 50002 "Contract Information"
{

    ApplicationArea = All;
    Caption = 'Contract Information';
    PageType = List;
    SourceTable = "Contract Information";
    UsageCategory = Lists;
    AutoSplitKey = true;
    DelayedInsert = true;
    //MultipleNewLines = true;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Order,Request Approval,History,Print/Send,Navigate';
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies the value of the Contract No. field.';
                    ApplicationArea = All;
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.';
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = All;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.';
                    ApplicationArea = All;
                }
                field("Contract Length"; Rec."Contract Length")
                {
                    ToolTip = 'Specifies the value of the Contract Length field.';
                    ApplicationArea = All;
                }
                field("Contract Start Date"; Rec."Contract Start Date")
                {
                    ToolTip = 'Specifies the value of the Contract Start Date field.';
                    ApplicationArea = All;
                }
                field("Invoice Interval"; Rec."Invoice Interval")
                {
                    ToolTip = 'Specifies the value of the Invoice Interval field.';
                    ApplicationArea = All;
                    Caption = 'Deferral Invoice';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                    ApplicationArea = All;
                }
                field(Currency; Rec.Currency)
                {
                    ToolTip = 'Specifies the value of the Currency field.';
                    ApplicationArea = All;
                }
                field("Unit Price Per Invoice Period"; Rec."Unit Price Per Invoice Period")
                {
                    ToolTip = 'Specifies the value of the Unit Price Per Invoice Period field.';
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Error Remarks"; Rec."Error Remarks")
                {
                    ToolTip = 'Specifies the value of the Error Remarks field.';
                    ApplicationArea = All;
                    Style = Attention;
                    Editable = false;
                }
                field("Sales Order No."; Rec."Sales Order No.")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Create Sales Order")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = SalesInvoice;
                trigger OnAction()
                var
                    ProcessSalesOrders: Report "Process Contract Information";
                    RecContractInformation: Record "Contract Information";
                begin
                    Clear(RecContractInformation);
                    CurrPage.SetSelectionFilter(RecContractInformation);
                    if RecContractInformation.FindSet() then begin
                        ProcessSalesOrders.ValidateRecord(RecContractInformation);
                        if not Confirm('Do you want to create Sales Order?', false) then
                            exit;
                        Clear(ProcessSalesOrders);
                        ProcessSalesOrders.SetTableView(RecContractInformation);
                        ProcessSalesOrders.Run();
                    end
                end;
            }
            action("Change Status")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Change;

                trigger OnAction()
                var
                    RecContractInformation: Record "Contract Information";
                begin
                    Clear(RecContractInformation);
                    CurrPage.SetSelectionFilter(RecContractInformation);
                    if RecContractInformation.FindSet() then begin
                        if not Confirm('Do you want to change the status?', false) then
                            exit;
                        repeat
                            //if not (RecContractInformation.Status in [RecContractInformation.Status::Error]) then
                            //    RecContractInformation.TestField(Status, RecContractInformation.Status::Error);
                            RecContractInformation.Status := RecContractInformation.Status::"Ready To Sync";
                            RecContractInformation."Error Remarks" := '';
                            RecContractInformation.Modify();
                        until
                        RecContractInformation.Next() = 0;
                    end
                end;
            }

            action("Sales Order Card")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Document;

                trigger OnAction()
                var
                    RecContractInformation: Record "Contract Information";
                    SalesOrderCard: page "Sales Order";
                    RecSalesHeader: Record "Sales Header";
                begin
                    Rec.TestField(Status, Rec.Status::Synced);
                    Clear(RecSalesHeader);
                    RecSalesHeader.SetRange("Document Type", RecSalesHeader."Document Type"::Order);
                    RecSalesHeader.SetRange("Contract No.", Rec."Contract No.");
                    RecSalesHeader.SetRange("Contract Line No.", Rec."Line No.");
                    if RecSalesHeader.FindFirst() then begin
                        Clear(SalesOrderCard);
                        SalesOrderCard.SetTableView(RecSalesHeader);
                        SalesOrderCard.Run();
                    end
                end;
            }
        }
    }
}
