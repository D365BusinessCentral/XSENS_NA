codeunit 50010 "XSS Check Sales Force Order"
{
    // version XSS5.006,XSS5.020


    trigger OnRun();
    begin
    end;

    var
        gCduAlgemeen: Codeunit Algemeen;
        gCduDimensionXsensMgt: Codeunit "Dimension Xsens  Mgt";

    procedure CheckOnRelease(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean);
    var
        lRecSalesLine: Record "Sales Line";
        lIntSortingNo: Integer;
    begin
        with lRecSalesLine do begin
            // Check the sorting number.
            SETRANGE("Document Type", "Document Type"::Order);
            SETRANGE("Document No.", SalesHeader."No.");
            SETRANGE(Sorting, 0);
            if FINDFIRST then begin
                repeat
                    if not "Checked by SalesForce" then begin
                        repeat
                            lIntSortingNo += 10;
                        until CheckSortingOrder(lRecSalesLine, lIntSortingNo);
                        Sorting := lIntSortingNo;
                        MODIFY(false);
                    end;
                until NEXT = 0;
            end;

            // Check the lines, for items and G/L accounts only.
            RESET;
            SETRANGE("Document Type", "Document Type"::Order);
            SETRANGE("Document No.", SalesHeader."No.");
            SETFILTER(Type, '%1|%2', Type::Item, Type::"G/L Account");
            if FINDFIRST then begin
                repeat
                    if not "Checked by SalesForce" then
                        CheckLine(SalesHeader, lRecSalesLine);
                until NEXT = 0;
            end;

            //Update the SalesForce flag.
            RESET;
            SETRANGE("Document Type", "Document Type"::Order);
            SETRANGE("Document No.", SalesHeader."No.");
            if FINDSET(true) then begin
                repeat
                    "Checked by SalesForce" := true;
                    MODIFY;
                until NEXT = 0;
            end;
        end;
    end;

    local procedure CheckLine(pRecSalesHeader: Record "Sales Header"; pRecSalesLine: Record "Sales Line");
    var
        lRecTMPSalesLine: Record "Sales Line" temporary;
        lCodeSaveTaxGroup: Code[20];
        lRecItem: Record Item;
    begin
        //TODO: Deze code graag reviewen. Wat gebeurt hier?
        //Save alle waardes in het record.
        lRecTMPSalesLine.DELETEALL(false);
        lRecTMPSalesLine := pRecSalesLine;
        lRecTMPSalesLine.INSERT(false);

        //JVW AANVULLING : Door deze validatie worden default waarden onvalidate weer gevuld op de verkoopregel.
        pRecSalesLine.VALIDATE("Bill-to Customer No.", lRecTMPSalesLine."Bill-to Customer No.");
        pRecSalesLine.VALIDATE(pRecSalesLine."No.");
        lRecItem.GET(pRecSalesLine."No.");

        lCodeSaveTaxGroup := pRecSalesLine."Tax Group Code";
        // hierna zijn alle waardes uit het oude record overrulled.
        // zet dus terug. dus.....
        // JVW AANVULLING: Waarschijnijk is de bedoeling dat info van stamgegevens hier opnieuwe moeten worden overgenomen van de stamgegevens of Header.
        // maatwerkvelden worden teruggezet op basis van invullen.
        // Dit kan ik analyseren op basis van code, ik vermoed dat Jeroen hier wel het fijne van weet .

        if lRecTMPSalesLine.Quantity <> 0 then begin //20110713 GFR 26096
            pRecSalesLine.VALIDATE(Quantity, lRecTMPSalesLine.Quantity);
            pRecSalesLine.VALIDATE("Unit Price", lRecTMPSalesLine."Unit Price");
            pRecSalesLine.VALIDATE("Unit Cost (LCY)", lRecTMPSalesLine."Unit Cost (LCY)");
            pRecSalesLine.VALIDATE("Line Discount %", lRecTMPSalesLine."Line Discount %");
            pRecSalesLine.VALIDATE("Line Discount Amount", lRecTMPSalesLine."Line Discount Amount");
            pRecSalesLine.VALIDATE(Description, lRecTMPSalesLine.Description);
            pRecSalesLine.VALIDATE("Description 2", lRecTMPSalesLine."Description 2");
            if pRecSalesLine."Description 2" = '' then
                pRecSalesLine.VALIDATE("Description 2", lRecItem."Description 2");

            pRecSalesLine.VALIDATE("Outstanding Amount", lRecTMPSalesLine."Outstanding Amount");
            pRecSalesLine.VALIDATE("Inv. Discount Amount", lRecTMPSalesLine."Inv. Discount Amount");
            pRecSalesLine.VALIDATE("Tax Area Code", lRecTMPSalesLine."Tax Area Code");
            pRecSalesLine.VALIDATE("Tax Liable", lRecTMPSalesLine."Tax Liable");
            pRecSalesLine.VALIDATE("Tax Group Code", lRecTMPSalesLine."Tax Group Code");
            pRecSalesLine.VALIDATE("Outstanding Amount (LCY)", lRecTMPSalesLine."Outstanding Amount (LCY)");
            pRecSalesLine.VALIDATE("Inv. Disc. Amount to Invoice", lRecTMPSalesLine."Inv. Disc. Amount to Invoice");
            if pRecSalesLine."Unit Price" <> 0 then begin
                pRecSalesLine.VALIDATE("Line Amount", lRecTMPSalesLine."Line Amount");
                pRecSalesLine.VALIDATE("Line Discount %", lRecTMPSalesLine."Line Discount %");
            end;
            pRecSalesLine.VALIDATE("Tax Group Code", lCodeSaveTaxGroup);
            pRecSalesLine.VALIDATE("Shipment Date", lRecTMPSalesLine."Shipment Date");
            //overnemen van het header.
            pRecSalesLine.VALIDATE("Tax Area Code", pRecSalesHeader."Tax Area Code");
            pRecSalesLine.VALIDATE("Tax Liable", pRecSalesHeader."Tax Liable");
        end;
        pRecSalesLine."Tax Group Code" := lCodeSaveTaxGroup;
        pRecSalesLine."Tax Area Code" := pRecSalesHeader."Tax Area Code";
        pRecSalesLine."Tax Liable" := pRecSalesHeader."Tax Liable";
        pRecSalesLine."Sales Order No." := lRecTMPSalesLine."Sales Order No.";
        pRecSalesLine."Sales Order Line No." := lRecTMPSalesLine."Sales Order Line No.";
        pRecSalesLine."Requested Delivery Date" := lRecTMPSalesLine."Requested Delivery Date";
        pRecSalesLine."Promised Delivery Date" := lRecTMPSalesLine."Promised Delivery Date";
        pRecSalesLine."Planned Delivery Date" := lRecTMPSalesLine."Planned Delivery Date";
        pRecSalesLine."Planned Shipment Date" := lRecTMPSalesLine."Planned Shipment Date";
        pRecSalesLine.Sorting := lRecTMPSalesLine.Sorting; //20130408 GW  30312
        pRecSalesLine.ExternalID := lRecTMPSalesLine.ExternalID;
        pRecSalesLine.COC := lRecTMPSalesLine.COC;  //20180417 KBG 12766
        pRecSalesLine.MODIFY(true);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Sorting', false, false)]
    local procedure ValidateSortingNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer);
    var
        lCtxSorting: TextConst ENU = 'Sorting number %1 is already in use.', NLD = 'Sorteringsnummer %1 is reedsl in gebruik.';
    begin
        if Rec.Sorting <> xRec.Sorting then
            if not (CheckSortingOrder(Rec, Rec.Sorting)) then
                ERROR(lCtxSorting, Rec.Sorting);
    end;

    local procedure CheckSortingOrder(pRecSalesLine: Record "Sales Line"; pSortingNo: Integer): Boolean;
    var
        lRecSalesLine: Record "Sales Line";
    begin
        if pSortingNo = 0 then
            exit(true);

        with lRecSalesLine do begin
            SETCURRENTKEY("Document Type", "Document No.", Sorting);
            SETRANGE("Document Type", "Document Type"::Order);
            SETRANGE("Document No.", pRecSalesLine."Document No.");
            SETRANGE(Sorting, pSortingNo);
            if lRecSalesLine.FINDFIRST then begin
                exit(false);
            end else
                exit(true);
        end;
    end;
}

