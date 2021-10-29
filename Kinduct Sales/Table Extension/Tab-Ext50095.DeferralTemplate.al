tableextension 50095 "Deferral Template" extends "Deferral Template"
{
    fields
    {
        field(50000; "Revenue Account"; Code[20])
        {
            Caption = 'Revenue Account';
            DataClassification = ToBeClassified;
            NotBlank = true;
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
    }
}
