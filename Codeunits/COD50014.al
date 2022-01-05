codeunit 50014 "Sales Order Customization"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure OnAfterValidateEvent(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    var
        CustomerL: Record Customer;
    begin
        if Rec."Document Type" IN [Rec."Document Type"::Order, Rec."Document Type"::Invoice] then begin
            if CustomerL.Get(Rec."Sell-to Customer No.") then begin
                case CustomerL."Shipment Method Code" of
                    'CPT':
                        Rec."Shipment Method Description" := 'Carriage Paid To address (excl. import cost) (Incoterms 2010)';
                    'DDP':
                        Rec."Shipment Method Description" := 'Delivered Duty Paid address (Incoterms 2010)';
                    'EXW':
                        Rec."Shipment Method Description" := 'EX-Works Enschede (Incoterms 2010)';
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Format Address", 'OnBeforeCompany', '', false, false)]
    local procedure OnBeforeCompany(var AddrArray: array[8] of Text[100];
    var CompanyInfo: Record "Company Information"; var IsHandled: Boolean)
    var
        FormatAddressCUL: Codeunit "Format Address";
    begin
        FormatAddressCUL.FormatAddr(
 AddrArray, CompanyInfo.Name, CompanyInfo."Name 2", '', CompanyInfo.Address, CompanyInfo."Address 2",
 CompanyInfo.City, CompanyInfo."Post Code", CompanyInfo.County, CompanyInfo."Country/Region Code");
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Format Address", 'OnBeforePurchHeaderShipTo', '', false, false)]
    local procedure OnBeforePurchHeaderShipTo(var AddrArray: array[8] of Text[100];
    var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    var
        FormatAddressCUL: Codeunit "Format Address";
    begin
        FormatAddressCUL.FormatAddr(
  AddrArray, PurchaseHeader."Ship-to Name", '', PurchaseHeader."Ship-to Contact", PurchaseHeader."Ship-to Address", PurchaseHeader."Ship-to Address 2",
  PurchaseHeader."Ship-to City", PurchaseHeader."Ship-to Post Code", PurchaseHeader."Ship-to County", PurchaseHeader."Ship-to Country/Region Code");
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Format Address", 'OnBeforeSalesHeaderShipTo', '', false, false)]
    local procedure OnBeforeSalesHeaderShipTo(var AddrArray: array[8] of Text[100]; var CustAddr: array[8] of Text[100];
    var Handled: Boolean; var Result: Boolean; var SalesHeader: Record "Sales Header")
    var
        FormatAddressCUL: Codeunit "Format Address";
    begin
        FormatAddressCUL.FormatAddr(
  AddrArray, SalesHeader."Ship-to Name", '', SalesHeader."Ship-to Contact", SalesHeader."Ship-to Address", SalesHeader."Ship-to Address 2",
  SalesHeader."Ship-to City", SalesHeader."Ship-to Post Code", SalesHeader."Ship-to County", SalesHeader."Ship-to Country/Region Code");
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Sales Orders", 'OnBeforeInsertReqWkshLine', '', false, false)]
    local procedure OnBeforeInsertReqWkshLine(SalesLine: Record "Sales Line"; SpecOrder: Integer;
    var ReqLine: Record "Requisition Line")
    begin
        ReqLine."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
        ReqLine."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";
        ReqLine."Dimension Set ID" := SalesLine."Dimension Set ID"
    end;
}