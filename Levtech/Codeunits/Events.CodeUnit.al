codeunit 50101 "Events"
{
    Permissions = tabledata 50011 = RIMD, tabledata 271 = RIMD;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Reconciliation Post", 'OnBeforeInitPost', '', false, false)]
    local procedure OnBeforeInitPost(var BankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        BankStatementL: Record "Bank Statement Report";
        OutStream: OutStream;
        InStream: InStream;
        BankReconStatementReport: Report "Bank Acc. Recon. - Test LT";
        RecBankAccRecon: Record "Bank Acc. Reconciliation";
        DocumentRef: RecordRef;
    begin
        // "Statement Type"::"Payment Application":
        //  "Statement Type"::"Bank Reconciliation":
        Clear(RecBankAccRecon);
        RecBankAccRecon.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        RecBankAccRecon.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        RecBankAccRecon.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        if RecBankAccRecon.FindFirst() then begin

            BankStatementL.Init();
            BankStatementL."Entry No." := 0;
            BankStatementL.Insert(true);
            BankStatementL."Bank Account No." := BankAccReconciliation."Bank Account No.";
            BankStatementL."Statement No." := BankAccReconciliation."Statement No.";
            BankStatementL."Statement Date" := BankAccReconciliation."Statement Date";

            Clear(OutStream);
            BankStatementL."PDF Report Data".CreateOutStream(OutStream);

            Clear(DocumentRef);
            DocumentRef.GetTable(RecBankAccRecon);

            Clear(BankReconStatementReport);
            BankReconStatementReport.UseRequestPage := false;
            BankReconStatementReport.SetPrintOutstandingTransactions(true);
            BankReconStatementReport.SetTableView(RecBankAccRecon);
            BankReconStatementReport.SaveAs('', ReportFormat::Pdf, OutStream, DocumentRef);

            Clear(OutStream);
            Clear(BankReconStatementReport);
            BankReconStatementReport.UseRequestPage := false;
            BankReconStatementReport.SetPrintOutstandingTransactions(true);
            BankReconStatementReport.SetTableView(RecBankAccRecon);
            BankStatementL."Excel Report Data".CreateOutStream(OutStream);
            BankReconStatementReport.SaveAs('', ReportFormat::Excel, OutStream, DocumentRef);
            BankStatementL.Modify(true);
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitBankAccLedgEntry', '', false, false)]
    local procedure OnAfterInitBankAccLedgEntry(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; GenJournalLine: Record "Gen. Journal Line");
    begin
        BankAccountLedgerEntry."Payment Method Code" := GenJournalLine."Payment Method Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Reconciliation Post", 'OnPostPaymentApplicationsOnAfterInitGenJnlLine', '', false, false)]
    local procedure OnPostPaymentApplicationsOnAfterInitGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line");
    begin
        GenJournalLine."Payment Method Code" := BankAccReconciliationLine."Payment Method Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnBeforePurchOrderLineInsert', '', false, false)]
    local procedure OnBeforePurchOrderLineInsert(var PurchOrderHeader: Record "Purchase Header"; var PurchOrderLine: Record "Purchase Line"; var ReqLine: Record "Requisition Line"; CommitIsSuppressed: Boolean);
    var
        RecVendor: Record Vendor;
        RecSalesLine: Record "Sales Line";
        RecSalesHeader: Record "Sales Header";
        CurrencyFactor, ExchangeRateAmt : Decimal;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        if PurchOrderHeader."Buy-from Vendor No." <> '' then begin
            Clear(RecVendor);
            if RecVendor.GET(PurchOrderHeader."Buy-from Vendor No.") then begin
                if RecVendor."Price Basis" = RecVendor."Price Basis"::Absolute then
                    exit
                else begin
                    Clear(RecSalesLine);
                    RecSalesLine.GET(RecSalesLine."Document Type"::Order, ReqLine."Sales Order No.", ReqLine."Sales Order Line No.");
                    Clear(RecSalesHeader);
                    RecSalesHeader.GET(RecSalesHeader."Document Type"::Order, ReqLine."Sales Order No.");
                    if RecSalesHeader."Currency Code" = PurchOrderHeader."Currency Code" then begin
                        PurchOrderLine.Validate("Direct Unit Cost", (RecSalesLine."Line Amount" * RecVendor.Percentage / 100) / RecSalesLine.Quantity);
                    end else begin

                        Clear(CurrencyFactor);
                        if PurchOrderHeader."Currency Factor" <> 0 then
                            CurrencyFactor := PurchOrderHeader."Currency Factor"
                        else
                            CurrencyFactor := 1;

                        Clear(CurrencyExchangeRate);
                        ExchangeRateAmt := CurrencyExchangeRate.GetCurrentCurrencyFactor(RecSalesHeader."Currency Code");
                        PurchOrderLine.Validate("Direct Unit Cost", Round((RecSalesLine."Unit Price" / CurrencyFactor) * ExchangeRateAmt, 0.01, '=') * RecVendor.Percentage / 100);
                    end;
                end;
            end;
        end
    end;

    //Calculate Amount LCY for Queries
    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnAfterValidateEventSalesInvLine(var Rec: Record "Sales Invoice Line"; RunTrigger: Boolean);
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if Rec."Document No." = '' then exit;
        Clear(SalesInvoiceHeader);
        if SalesInvoiceHeader.GET(Rec."Document No.") then begin
            if SalesInvoiceHeader."Currency Factor" <> 0 then
                Rec."Amount LCY" := Rec.Amount / SalesInvoiceHeader."Currency Factor"
            else
                Rec."Amount LCY" := Rec.Amount;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnAfterValidateEventSalesCrMemoLine(var Rec: Record "Sales Cr.Memo Line"; RunTrigger: Boolean);
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if Rec."Document No." = '' then exit;
        Clear(SalesCrMemoHeader);
        if SalesCrMemoHeader.GET(Rec."Document No.") then begin
            if SalesCrMemoHeader."Currency Factor" <> 0 then
                Rec."Amount LCY" := Rec.Amount / SalesCrMemoHeader."Currency Factor"
            else
                Rec."Amount LCY" := Rec.Amount;
        end;
    end;

    procedure OpenbankLedgerEntry(var RecBankLedger: Record "Bank Account Ledger Entry")
    begin
        if RecBankLedger.FindSet() then begin
            repeat
                RecBankLedger.Open := true;
                RecBankLedger."Statement Status" := RecBankLedger."Statement Status"::Open;
                RecBankLedger."Remaining Amount" := RecBankLedger.Amount;
                RecBankLedger."Statement No." := '';
                RecBankLedger."Statement Line No." := 0;
                RecBankLedger.Modify();
            until RecBankLedger.Next() = 0;
        end

    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopySellToCustomerAddressFieldsFromCustomer', '', false, false)]
    local procedure OnAfterCopySellToCustomerAddressFieldsFromCustomer(var SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer; CurrentFieldNo: Integer; var SkipBillToContact: Boolean);
    begin
        //CH-20210507-02 -->
        SalesHeader."VAT Customer Name" := SellToCustomer."VAT Customer Name";
        SalesHeader."VAT Address & Telephone" := SellToCustomer."VAT Address & Telephone";
        SalesHeader."VAT Bank Name & Account" := SellToCustomer."VAT Bank Name & Account";
        SalesHeader."VAT Invoice Mail Address" := SellToCustomer."VAT Invoice Mail Address";
        SalesHeader."VAT Contact Information" := SellToCustomer."VAT Contact Information";
        SalesHeader."Sell-to Customer Name 3" := SellToCustomer."Name 3";
        //CH-20210507-02 <--
        //LT-28JULY2021 -->
        SalesHeader."Application area" := SellToCustomer."Application area";
        //LT-28JULY2021 <--
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnShowDocDimOnBeforeUpdateSalesLines', '', false, false)]
    local procedure OnShowDocDimOnBeforeUpdateSalesLines(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header");
    var
        RecGLSetup: Record "General Ledger Setup";
        RecDimSetEntry: Record "Dimension Set Entry";
    begin
        RecGLSetup.GET;
        CLEAR(RecDimSetEntry);
        IF RecDimSetEntry.GET(SalesHeader."Dimension Set ID", RecGLSetup."Shortcut Dimension 4 Code") THEN
            SalesHeader."Shortcut Dimension 4 Code" := RecDimSetEntry."Dimension Value Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterShowDimensions', '', false, false)]
    local procedure OnAfterShowDimensions(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line");
    var
        RecGLSetup: Record "General Ledger Setup";
        RecDimSetEntry: Record "Dimension Set Entry";
    begin
        if SalesLine."Dimension Set ID" <> xSalesLine."Dimension Set ID" then begin
            RecGLSetup.GET;
            CLEAR(RecDimSetEntry);
            IF RecDimSetEntry.GET(SalesLine."Dimension Set ID", RecGLSetup."Shortcut Dimension 4 Code") THEN
                SalesLine."Shortcut Dimension 4 Code" := RecDimSetEntry."Dimension Value Code";
        end;
    end;

    //For IC related fields 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ICInboxOutboxMgt, 'OnCreateSalesDocumentOnBeforeSalesHeaderModify', '', false, false)]
    local procedure OnCreateSalesDocumentOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header"; ICInboxSalesHeader: Record "IC Inbox Sales Header");
    begin
        SalesHeader."Ship-to Contact" := ICInboxSalesHeader."Ship-to Contact";                          // 20100930 TG 23475
        SalesHeader."Ship-to Country/Region Code" := ICInboxSalesHeader."Ship-to Country/Region Code";              //20110103 GFR 25048
        SalesHeader."Salesperson Code" := ICInboxSalesHeader."Salesperson Code";                         // 20101001 TG 23475
        SalesHeader."Your Reference" := ICInboxSalesHeader."Sales Your Reference";                     // 20101001 TG 23475
        SalesHeader."Quote No." := ICInboxSalesHeader."Sales Quote No.";                          // 20101001 TG 23475
        SalesHeader."US Payment Terms" := ICInboxSalesHeader."US Payment terms";                         // 20160512 KBG 06458
        SalesHeader."US Sales Order No." := ICInboxSalesHeader."US Sales Order number";                    // 20160512 KBG 06458
        SalesHeader."SalesForce Comment" := ICInboxSalesHeader."SalesForce Comment";                       // 20160914 KBG 07441
        SalesHeader."Comment 2" := ICInboxSalesHeader."Comment 2";                                // 20160914 KBG 07441

        //NM_BEGIN 20110415 GFR 25421
        SalesHeader."Sell-to IC Customer No." := ICInboxSalesHeader."Sell-to IC Customer No.";
        SalesHeader."Sell-to IC Name" := ICInboxSalesHeader."Sell-to IC Name";
        SalesHeader."Sell-to IC Name 2" := ICInboxSalesHeader."Sell-to IC Name 2";
        SalesHeader."Sell-to IC Address" := ICInboxSalesHeader."Sell-to IC Address";
        SalesHeader."Sell-to IC Address 2" := ICInboxSalesHeader."Sell-to IC Address 2";
        SalesHeader."Sell-to IC City" := ICInboxSalesHeader."Sell-to IC City";
        SalesHeader."Sell-to IC Contact" := ICInboxSalesHeader."Sell-to IC Contact";
        SalesHeader."Sell-to IC Post Code" := ICInboxSalesHeader."Sell-to IC Post Code";
        //NM_END 20110415 GFR 25421

        // NM_BEGIN 20100829 TG 23475
        IF ICInboxSalesHeader."Expected Receipt Date" <> 0D THEN BEGIN
            SalesHeader.VALIDATE("Shipment Date", ICInboxSalesHeader."Expected Receipt Date");
        END;
        // NM_BEGIN 20100829 TG 23475
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ICInboxOutboxMgt, 'OnCreateSalesLinesOnBeforefterAssignTypeAndNo', '', false, false)]
    local procedure OnCreateSalesLinesOnBeforefterAssignTypeAndNo(var SalesLine: Record "Sales Line"; ICInboxSalesLine: Record "IC Inbox Sales Line");
    var
        RecSalesHeader: Record "Sales Header";
        lRecSalesperson: Record "Salesperson/Purchaser";
    begin

        Clear(RecSalesHeader);
        RecSalesHeader.SetRange("Document Type", SalesLine."Document Type");
        RecSalesHeader.SetRange("No.", SalesLine."Document No.");
        if RecSalesHeader.FindFirst() then begin
            // RecSalesHeader."US Payment Terms" := ICInboxSalesLine."Payment Terms Code (US)";
            // RecSalesHeader."US Sales Order No." := ICInboxSalesLine."Sales Order No. (US)";
            // RecSalesHeader."SalesForce Comment" := ICInboxSalesLine."SalesForce Comment";
            // RecSalesHeader."Comment 2" := ICInboxSalesLine."SalesForce Comment 2";
            // RecSalesHeader."Your Reference" := ICInboxSalesLine."Your Reference (US)";
            // IF ICInboxSalesLine."Sales Person Code (US)" <> '' THEN
            //     IF lRecSalesperson.GET(ICInboxSalesLine."Sales Person Code (US)") THEN
            //         RecSalesHeader.VALIDATE("Salesperson Code", ICInboxSalesLine."Sales Person Code (US)");
            IF ICInboxSalesLine."Business Unit Code (US)" <> '' THEN
                RecSalesHeader.VALIDATE("Shortcut Dimension 1 Code", ICInboxSalesLine."Business Unit Code (US)");
            RecSalesHeader.MODIFY;
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ICInboxOutboxMgt, 'OnAfterCreateSalesDocument', '', false, false)]
    local procedure OnAfterCreateSalesDocument(var SalesHeader: Record "Sales Header"; ICInboxSalesHeader: Record "IC Inbox Sales Header"; HandledICInboxSalesHeader: Record "Handled IC Inbox Sales Header");
    var
        lRecSalesLineFROM: Record "Sales Line";
        lRecSalesLineTO: Record "Sales Line";
        CompanyInfo: Record "Company Information";
        pTxtCompanyName: Text;
        lIntLineNo: Integer;
    begin
        CompanyInfo.GET;
        pTxtCompanyName := CompanyInfo."Company Name for Intercompany";
        IF pTxtCompanyName = '' THEN EXIT;
        lRecSalesLineFROM.CHANGECOMPANY(pTxtCompanyName);

        lIntLineNo := 0;
        lRecSalesLineTO.RESET;
        lRecSalesLineTO.SETCURRENTKEY("Document Type", "Document No.");
        lRecSalesLineTO.SETRANGE("Document Type", SalesHeader."Document Type");
        lRecSalesLineTO.SETRANGE("Document No.", SalesHeader."No.");
        IF lRecSalesLineTO.FINDLAST THEN
            lIntLineNo := lRecSalesLineTO."Line No.";

        lRecSalesLineFROM.RESET;
        lRecSalesLineFROM.SETCURRENTKEY("Document Type", "Document No.");
        lRecSalesLineFROM.SETRANGE("Document Type", SalesHeader."Document Type");
        lRecSalesLineFROM.SETRANGE("Document No.", SalesHeader."US Sales Order No.");
        lRecSalesLineFROM.SETRANGE(Type, lRecSalesLineFROM.Type::" ");
        IF lRecSalesLineFROM.FINDFIRST THEN BEGIN
            REPEAT
                ;
                lIntLineNo := lIntLineNo + 10000;
                lRecSalesLineTO.TRANSFERFIELDS(lRecSalesLineFROM, TRUE);
                lRecSalesLineTO."Document No." := SalesHeader."No.";
                lRecSalesLineTO."Line No." := lIntLineNo;
                lRecSalesLineTO.INSERT;
            UNTIL lRecSalesLineFROM.NEXT = 0;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ICInboxOutboxMgt, 'OnAfterCreateSalesLines', '', false, false)]
    local procedure OnAfterCreateSalesLines(ICInboxSalesLine: Record "IC Inbox Sales Line"; var SalesLine: Record "Sales Line");
    begin
        // NM_BEGIN 20100829 TG 23475
        SalesLine."Sales Order No." := ICInboxSalesLine."Sales Order No.";
        SalesLine."Sales Order Line No." := ICInboxSalesLine."Sales Order Line No.";
        SalesLine."Shipment Date" := ICInboxSalesLine."Shipment Date";          // 20160510 KBG 06458
        SalesLine."Sorting" := ICInboxSalesLine.Sorting;                  // 20160510 KBG 06458
                                                                          // NM_END 20100829 TG 23475
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ICInboxOutboxMgt, 'OnBeforeICInboxPurchLineInsert', '', false, false)]
    local procedure OnBeforeICInboxPurchLineInsert(var ICInboxPurchaseLine: Record "IC Inbox Purchase Line"; ICOutboxSalesLine: Record "IC Outbox Sales Line");
    begin
        // NM_BEGIN 20100830 TG 23475
        ICInboxPurchaseLine."Sales Order No." := ICOutboxSalesLine."Sales Order No.";
        ICInboxPurchaseLine."Sales Order Line No." := ICOutboxSalesLine."Sales Order Line No.";
        //ICInboxPurchLine."Shortcut Dimension 1 Code" := ICOutboxSalesLine."Shortcut Dimension 1 Code";  // 20111207 GFR 27136
        //ICInboxPurchLine."Shortcut Dimension 2 Code" := ICOutboxSalesLine."Shortcut Dimension 2 Code";  // 20111207 GFR 27136
        ICInboxPurchaseLine."Shipment Date" := ICOutboxSalesLine."Shipment Date";              // 20160510 KBG 06458
        ICInboxPurchaseLine.Sorting := ICOutboxSalesLine.Sorting;                      // 20160510 KBG 06458
                                                                                       // NM_END 20100830 TG 23475
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ICInboxOutboxMgt, 'OnBeforeICInboxSalesHeaderInsert', '', false, false)]
    local procedure OnBeforeICInboxSalesHeaderInsert(var ICInboxSalesHeader: Record "IC Inbox Sales Header"; ICOutboxPurchaseHeader: Record "IC Outbox Purchase Header");
    begin
        //NM_BEGIN 20110415 GFR 25421
        ICInboxSalesHeader."Sell-to IC Customer No." := ICOutboxPurchaseHeader."Sell-to IC Customer No.";
        ICInboxSalesHeader."Sell-to IC Name" := ICOutboxPurchaseHeader."Sell-to IC Name";
        ICInboxSalesHeader."Sell-to IC Name 2" := ICOutboxPurchaseHeader."Sell-to IC Name 2";
        ICInboxSalesHeader."Sell-to IC Address" := ICOutboxPurchaseHeader."Sell-to IC Address";
        ICInboxSalesHeader."Sell-to IC Address 2" := ICOutboxPurchaseHeader."Sell-to IC Address 2";
        ICInboxSalesHeader."Sell-to IC City" := ICOutboxPurchaseHeader."Sell-to IC City";
        ICInboxSalesHeader."Sell-to IC Contact" := ICOutboxPurchaseHeader."Sell-to IC Contact";
        ICInboxSalesHeader."Sell-to IC Post Code" := ICOutboxPurchaseHeader."Sell-to IC Post Code";
        ICInboxSalesHeader."Ship-to Contact" := ICOutboxPurchaseHeader."Ship-to Contact";   // 20100930 TG 23475
        ICInboxSalesHeader."Ship-to Country/Region Code" := ICOutboxPurchaseHeader."Ship-to Country/Region Code";
        ICInboxSalesHeader."US Payment terms" := ICOutboxPurchaseHeader."Payment Terms Code (US)";    //20160512 KBG 06458
        ICInboxSalesHeader."US Sales Order number" := ICOutboxPurchaseHeader."Sales Order No. (US)";       //20160512 KBG 05468
        ICInboxSalesHeader."SalesForce Comment" := ICOutboxPurchaseHeader."SalesForce Comment";         //20160914 KBG 07441
        ICInboxSalesHeader."Comment 2" := ICOutboxPurchaseHeader."SalesForce Comment 2";       //20160914 KBG 07441
        //NM_END 20110415 GFR 25421
        ICInboxSalesHeader."Salesperson Code" := ICOutboxPurchaseHeader."Salesperson Code";
        ICInboxSalesHeader."Sales Your Reference" := ICOutboxPurchaseHeader."Sales Your Reference";
        ICInboxSalesHeader."Sales Quote No." := ICOutboxPurchaseHeader."Sales Quote No.";
        //ICInboxSalesHdr."Shortcut Dimension 1 Code"   := ICOutboxPurchHdr."Shortcut Dimension 1 Code";  // 20111207 GFR 27136
        //ICInboxSalesHdr."Shortcut Dimension 2 Code"   := ICOutboxPurchHdr."Shortcut Dimension 2 Code";  // 20111207 GFR 27136
        // NM_BEGIN 20100829 TG 23474
        IF ICOutboxPurchaseHeader."Expected Receipt Date" <> 0D THEN BEGIN
            ICInboxSalesHeader."Expected Receipt Date" := ICOutboxPurchaseHeader."Expected Receipt Date";
        END;
        // NM_END 20100829 TG 23474

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ICInboxOutboxMgt, 'OnBeforeICInboxSalesLineInsert', '', false, false)]
    local procedure OnBeforeICInboxSalesLineInsert(var ICInboxSalesLine: Record "IC Inbox Sales Line"; ICOutboxPurchaseLine: Record "IC Outbox Purchase Line");
    begin
        // NM_BEGIN 20100829 TG 23475
        ICInboxSalesLine."Sales Order No." := ICOutboxPurchaseLine."Sales Order No.";
        ICInboxSalesLine."Sales Order Line No." := ICOutboxPurchaseLine."Sales Order Line No.";
        //ICInboxSalesLine."Shortcut Dimension 1 Code" := ICOutboxPurchLine."Shortcut Dimension 1 Code";  // 20111207 GFR 27136
        //ICInboxSalesLine."Shortcut Dimension 2 Code" := ICOutboxPurchLine."Shortcut Dimension 2 Code";  // 20111207 GFR 27136
        ICInboxSalesLine."Shipment Date" := ICOutboxPurchaseLine."Shipment Date";              // 20160510 KBG 06458
        ICInboxSalesLine.Sorting := ICOutboxPurchaseLine.Sorting;                      // 20160510 KBG 06458
                                                                                       // NM_END 20100829 TG 23475
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterInsertPurchOrderHeader', '', false, false)]
    local procedure OnAfterInsertPurchOrderHeader(var RequisitionLine: Record "Requisition Line"; var PurchaseOrderHeader: Record "Purchase Header"; CommitIsSuppressed: Boolean; SpecialOrder: Boolean);
    var
        SalesHeader: Record "Sales Header";
    begin
        if not SpecialOrder then begin
            if SalesHeader.Get(SalesHeader."Document Type"::Order, RequisitionLine."Sales Order No.") then begin
                PurchaseOrderHeader."Sales Order no." := SalesHeader."No.";
            end;

        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ICInboxOutboxMgt, 'OnCreateOutboxPurchDocTransOnAfterTransferFieldsFromPurchHeader', '', false, false)]
    local procedure OnCreateOutboxPurchDocTransOnAfterTransferFieldsFromPurchHeader(var ICOutboxPurchHeader: Record "IC Outbox Purchase Header"; PurchHeader: Record "Purchase Header");
    var
        lRecSalesHeader: Record "Sales Header";
    begin
        //ICOutBoxPurchHeader."Ship-to Post Code"             := PurchHeader."Ship-to Post Code";           // 20100929 TG 23475
        //ICOutBoxPurchHeader."Ship-to Address 2"             := PurchHeader."Ship-to Address 2";           // 20100928 TG 23475
        ICOutBoxPurchHeader."Ship-to Contact" := PurchHeader."Ship-to Contact";             // 20100930 TG 23475
        ICOutBoxPurchHeader."Salesperson Code" := PurchHeader."Salesperson Code";            // 20101001 TG 23475
        ICOutBoxPurchHeader."Sales Your Reference" := PurchHeader."Sales Your Reference";        // 20101001 TG 23475
        ICOutBoxPurchHeader."Sales Quote No." := PurchHeader."Sales Quote No.";             // 20101001 TG 23475

        //NM_BEGIN 20110415 GFR 25468
        IF lRecSalesHeader.GET(PurchHeader."Document Type"::Order, PurchHeader."Sales Order no.") THEN BEGIN
            ICOutBoxPurchHeader."Sell-to IC Customer No." := PurchHeader."Sell-to Customer No.";
            ICOutBoxPurchHeader."Sell-to IC Name" := lRecSalesHeader."Sell-to Customer Name";
            ICOutBoxPurchHeader."Sell-to IC Name 2" := lRecSalesHeader."Sell-to Customer Name 2";
            ICOutBoxPurchHeader."Sell-to IC Address" := lRecSalesHeader."Sell-to Address";
            ICOutBoxPurchHeader."Sell-to IC Address 2" := lRecSalesHeader."Sell-to Address 2";
            ICOutBoxPurchHeader."Sell-to IC City" := lRecSalesHeader."Sell-to City";
            ICOutBoxPurchHeader."Sell-to IC Contact" := lRecSalesHeader."Sell-to Contact";
            ICOutBoxPurchHeader."Sell-to IC Post Code" := lRecSalesHeader."Sell-to Post Code";
            ICOutBoxPurchHeader."Payment Terms Code (US)" := lRecSalesHeader."Payment Terms Code";       //20160512 KBG 06458
            ICOutBoxPurchHeader."Sales Order No. (US)" := lRecSalesHeader."No.";                      //20160512 KBG 06458
            ICOutBoxPurchHeader."SalesForce Comment" := lRecSalesHeader."SalesForce Comment";       //20160914 KBG 07441
            ICOutBoxPurchHeader."SalesForce Comment 2" := lRecSalesHeader."Comment 2";                //20160914 KBG 07441
            ICOutBoxPurchHeader."Sales Your Reference" := lRecSalesHeader."Your Reference";
            ICOutBoxPurchHeader."Salesperson Code" := lRecSalesHeader."Salesperson Code";
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ICInboxOutboxMgt, 'OnCreateOutboxPurchDocTransOnAfterICOutBoxPurchLineInsert', '', false, false)]
    local procedure OnCreateOutboxPurchDocTransOnAfterICOutBoxPurchLineInsert(var ICOutboxPurchaseLine: Record "IC Outbox Purchase Line"; PurchaseLine: Record "Purchase Line");
    var
        lRecSalesLine: Record "Sales Line";
    begin
        // NM_BEGIN 20100829 TG 23475
        ICOutboxPurchaseLine."Sales Order No." := PurchaseLine."Sales Order No.";
        ICOutboxPurchaseLine."Sales Order Line No." := PurchaseLine."Sales Order Line No.";
        //"Shortcut Dimension 1 Code" := PurchLine."Shortcut Dimension 1 Code"; // 20111207 GFR 27136:
        //"Shortcut Dimension 2 Code" := PurchLine."Shortcut Dimension 2 Code"; // 20111207 GFR 27136:
        IF lRecSalesLine.GET(lRecSalesLine."Document Type"::Order, PurchaseLine."Sales Order no.",
            PurchaseLine."Sales Order Line No.") THEN BEGIN
            ICOutboxPurchaseLine."Shipment Date" := lRecSalesLine."Shipment Date";         // 20160510 KBG 06458
            ICOutboxPurchaseLine.Sorting := lRecSalesLine."Sorting";                 // 20160510 KBG 06458
        END;
        ICOutboxPurchaseLine.Modify();
        // NM_END 20100829 TG 23475
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IC Outbox Export", 'OnBeforeExportOutboxTransaction', '', false, false)]
    local procedure OnBeforeExportOutboxTransaction(ICOutboxTransaction: Record "IC Outbox Transaction"; OutStr: OutStream; var IsHandled: Boolean);
    var
        ICOutboxImpExpXML: XMLport "IC Outbox Imp/Exp_Intwo";
        ICOutboxTransaction2: Record "IC Outbox Transaction";
    begin
        Clear(ICOutboxTransaction2);
        Clear(ICOutboxImpExpXML);
        // ICOutboxTransaction2.SetRange("Transaction No.", ICOutboxTransaction."Transaction No.");
        // ICOutboxTransaction2.SetRange("IC Partner Code", ICOutboxTransaction."IC Partner Code");
        // ICOutboxTransaction2.SetRange("Transaction Source", ICOutboxTransaction."Transaction Source");
        // ICOutboxTransaction2.SetRange("Document Type", ICOutboxTransaction."Document Type");
        ICOutboxTransaction2.SetRange("Line Action", ICOutboxTransaction2."Line Action"::"Send to IC Partner");
        if ICOutboxTransaction2.FindSet() then begin
            ICOutboxImpExpXML.SetICOutboxTrans(ICOutboxTransaction2);
            ICOutboxImpExpXML.SetDestination(OutStr);
            ICOutboxImpExpXML.Export;
        end;
        IsHandled := true;
        Clear(OutStr);
        Clear(ICOutboxImpExpXML);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IC Inbox Import", 'OnBeforeImportInboxTransaction', '', false, false)]
    local procedure OnBeforeImportInboxTransaction(CompanyInfo: Record "Company Information"; var IStream: InStream; var TempICOutboxTransaction: Record "IC Outbox Transaction"; var TempICOutboxJnlLine: Record "IC Outbox Jnl. Line"; var TempICInboxOutboxJnlLineDim: Record "IC Inbox/Outbox Jnl. Line Dim."; var TempICOutboxSalesHeader: Record "IC Outbox Sales Header"; var TempICOutboxSalesLine: Record "IC Outbox Sales Line"; var TempICOutboxPurchaseHeader: Record "IC Outbox Purchase Header"; var TempICOutboxPurchaseLine: Record "IC Outbox Purchase Line"; var TempICDocDim: Record "IC Document Dimension"; var FromICPartnerCode: Code[20]; var IsHandled: Boolean);
    var
        ICPartner: Record "IC Partner";
        ICOutboxImpExpXML: XMLport "IC Outbox Imp/Exp_Intwo";
        IFile: File;
        ToICPartnerCode: Code[20];
        WrongCompanyErr: Label 'The selected xml file contains data sent to %1 %2. Current company''s %3 is %4.', Comment = 'The selected xml file contains data sent to IC Partner 001. Current company''s IC Partner Code is 002.';
    begin

        ICOutboxImpExpXML.SetSource(IStream);
        ICOutboxImpExpXML.Import;

        FromICPartnerCode := ICOutboxImpExpXML.GetFromICPartnerCode;
        ToICPartnerCode := ICOutboxImpExpXML.GetToICPartnerCode;
        if ToICPartnerCode <> CompanyInfo."IC Partner Code" then
            Error(
              WrongCompanyErr, ICPartner.TableCaption, ToICPartnerCode,
              CompanyInfo.FieldCaption("IC Partner Code"), CompanyInfo."IC Partner Code");

        ICOutboxImpExpXML.GetICOutboxTrans(TempICOutboxTransaction);
        ICOutboxImpExpXML.GetICOutBoxJnlLine(TempICOutboxJnlLine);
        ICOutboxImpExpXML.GetICIOBoxJnlDim(TempICInboxOutboxJnlLineDim);
        ICOutboxImpExpXML.GetICOutBoxSalesHdr(TempICOutboxSalesHeader);
        ICOutboxImpExpXML.GetICOutBoxSalesLine(TempICOutboxSalesLine);
        ICOutboxImpExpXML.GetICOutBoxPurchHdr(TempICOutboxPurchaseHeader);
        ICOutboxImpExpXML.GetICOutBoxPurchLine(TempICOutboxPurchaseLine);
        ICOutboxImpExpXML.GetICSalesDocDim(TempICDocDim);
        ICOutboxImpExpXML.GetICSalesDocLineDim(TempICDocDim);
        ICOutboxImpExpXML.GetICPurchDocDim(TempICDocDim);
        ICOutboxImpExpXML.GetICPurchDocLineDim(TempICDocDim);
        FromICPartnerCode := ICOutboxImpExpXML.GetFromICPartnerCode;

        IsHandled := true;
    end;

    var
        x: XmlPort 12;
        c: Codeunit 435;
        d: Page "Service Item Component List";
        f: Codeunit "Sales-Post";
        g: page "Sales Order";
        h: page "IC Outbox Transactions";
}