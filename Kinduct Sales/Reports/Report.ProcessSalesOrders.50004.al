report 50021 "Process Contract Information"
{
    ProcessingOnly = true;
    UseRequestPage = false;
    dataset
    {
        dataitem("Contract Information"; "Contract Information")
        {
            DataItemTableView = sorting("Contract No.") order(ascending) where(Status = const("Ready To Sync"));
            trigger OnAfterGetRecord()
            begin
                ClearLastError();
                Commit();
                if Codeunit.Run(Codeunit::"Process Contract Information", "Contract Information") then begin
                    "Contract Information".Status := "Contract Information".Status::Synced;
                    //"Contract Information"."Sales Order No." := "Contract Information"."No.";
                    "Contract Information"."Error Remarks" := '';
                    "Contract Information".Modify();
                end else begin
                    "Contract Information".Status := "Contract Information".Status::Error;
                    //"Contract Information"."Sales Order No." := '';
                    "Contract Information"."Error Remarks" := CopyStr(GetLastErrorText, 1, 250);
                    "Contract Information".Modify();
                end;
            end;

            trigger OnPostDataItem()
            var

            begin


            end;
        }
    }
    procedure ValidateRecord(var Header: Record "Contract Information")
    begin
        if Header.FindSet() then begin
            repeat
                Header.TestField(Status, Header.Status::"Ready To Sync");
            until Header.Next() = 0;
        end
    end;
}