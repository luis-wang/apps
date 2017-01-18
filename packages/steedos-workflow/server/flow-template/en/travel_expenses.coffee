workflowTemplate["en"].push {
	"_id": "CB73FBA0-44D1-4E83-B240-B65BFB20E417",
	"name": "Travel Expenses",
	"state": "enabled",
	"is_deleted": false,
	"is_valid": true,
	"space": "526785fb3349041651000a75",
	"description": "",
	"is_subform": false,
	"created": "2013-11-08T09:53:09.007Z",
	"created_by": "519978e28e296a2fef000012",
	"current": {
		"_id": "8d9d4f21-f8ed-4a07-9740-76b7acfbd1e8",
		"_rev": 3,
		"created": "2014-01-24T01:52:05.657Z",
		"created_by": "519978e28e296a2fef000012",
		"modified": "2014-01-24T01:52:13.169Z",
		"modified_by": "519978e28e296a2fef000012",
		"start_date": "2014-01-24T01:52:13.169Z",
		"form": "CB73FBA0-44D1-4E83-B240-B65BFB20E417",
		"fields": [
			{
				"_id": "6A16CDEE-CEE4-40E5-B863-371D7214399C",
				"code": "Requestor Department",
				"is_required": false,
				"is_wide": true,
				"type": "input",
				"rows": 4,
				"digits": 0,
				"formula": "{applicant.organization.fullname}",
				"has_others": false,
				"is_multiselect": false,
				"subform_fields": [],
				"fields": []
			},
			{
				"_id": "32D4A852-F38C-4AEF-9F6C-ED2D14D85A9B",
				"code": " Travel Details",
				"is_required": false,
				"is_wide": true,
				"type": "section",
				"rows": 4,
				"digits": 0,
				"has_others": false,
				"is_multiselect": false,
				"subform_fields": [],
				"fields": [
					{
						"_id": "EB1F28AC-947B-433C-9806-C0F6F01E1EE2",
						"code": "Purpose of Travel",
						"is_required": true,
						"is_wide": true,
						"type": "input",
						"rows": 4,
						"digits": 0,
						"has_others": false,
						"is_multiselect": false
					},
					{
						"_id": "33F0A09C-C8C8-4C36-BAD7-7CDB603605B9",
						"code": "From Date",
						"is_required": true,
						"is_wide": false,
						"type": "date",
						"rows": 4,
						"digits": 0,
						"has_others": false,
						"is_multiselect": false
					},
					{
						"_id": "CAEF22A0-14B9-4B10-A756-708C12E5A8A9",
						"code": "To Date",
						"is_required": true,
						"is_wide": false,
						"type": "date",
						"rows": 4,
						"digits": 0,
						"has_others": false,
						"is_multiselect": false
					}
				]
			},
			{
				"_id": "DA84D265-0CAB-41D4-80FE-2851FA71B691",
				"code": "Expense Details",
				"is_required": false,
				"is_wide": true,
				"type": "table",
				"rows": 4,
				"digits": 0,
				"has_others": false,
				"is_multiselect": false,
				"subform_fields": [],
				"fields": [
					{
						"_id": "CE2A5CC3-4C9C-4190-BC2F-A5D0B1197446",
						"code": "Expense Type",
						"default_value": "",
						"is_required": true,
						"is_wide": false,
						"type": "select",
						"rows": 4,
						"digits": 0,
						"options": "Flights\nTransportation\nLodging\nMeal\nConference & Seminar Fees\nEntertainment\nOthers",
						"has_others": false,
						"is_multiselect": false,
						"oldCode": "Expense Type"
					},
					{
						"_id": "4208F7EB-A2CA-44D2-9481-5B0BC86107D3",
						"code": "Expense Date",
						"is_required": false,
						"is_wide": false,
						"type": "date",
						"rows": 4,
						"digits": 0,
						"has_others": false,
						"is_multiselect": false
					},
					{
						"_id": "EDA46FA8-047C-42E5-BF23-D630B288AD1D",
						"code": "Amount",
						"is_required": true,
						"is_wide": false,
						"type": "number",
						"rows": 4,
						"digits": 2,
						"has_others": false,
						"is_multiselect": false,
						"oldCode": "Expense Amount"
					},
					{
						"_id": "FF5D4EC8-7AF3-4FF9-9D55-4216CB88F5AA",
						"code": "Comments",
						"is_required": false,
						"is_wide": true,
						"type": "input",
						"rows": 4,
						"digits": 0,
						"has_others": false,
						"is_multiselect": false,
						"oldCode": "Description"
					}
				]
			},
			{
				"_id": "C06462AA-E5FF-44D4-AF1B-C4B60082D7A4",
				"name": "",
				"code": "Total Amount",
				"is_required": false,
				"is_wide": false,
				"type": "number",
				"rows": 4,
				"digits": 2,
				"formula": "sum({Amount})",
				"has_others": false,
				"is_multiselect": false,
				"subform_fields": [],
				"fields": []
			},
			{
				"_id": "D37A6AFE-8AD5-4E0E-AB5C-BC850FFA45B8",
				"code": "Total Prepaid by Company",
				"is_required": false,
				"is_wide": false,
				"type": "number",
				"rows": 4,
				"digits": 2,
				"has_others": false,
				"is_multiselect": false,
				"subform_fields": [],
				"fields": []
			},
			{
				"_id": "F0AA23C4-5182-46F9-8B7B-7E1F754E5915",
				"code": "Total Amount Requested",
				"is_required": false,
				"is_wide": false,
				"type": "number",
				"rows": 4,
				"digits": 2,
				"formula": "{Total Amount}-{Total Prepaid by Company}",
				"has_others": false,
				"is_multiselect": false,
				"subform_fields": [],
				"fields": []
			}
		]
	},
	"enable_workflow": false,
	"enable_view_others": false,
	"app": "workflow",
	"approve_on_create": false,
	"approve_on_delete": false,
	"approve_on_modify": false,
	"historys": [],
	"flows": [
		{
			"_id": "5C708489-EE98-4DAC-BC23-C9640CE3C6AE",
			"name": "Travel Expenses",
			"name_formula": "",
			"code_formula": "",
			"space": "526785fb3349041651000a75",
			"description": "",
			"is_valid": true,
			"form": "CB73FBA0-44D1-4E83-B240-B65BFB20E417",
			"flowtype": "new",
			"state": "enabled",
			"is_deleted": false,
			"created": "2013-11-08T10:37:13.440Z",
			"created_by": "519978e28e296a2fef000012",
			"help_text": "",
			"current_no": 1,
			"current": {
				"_id": "e855b833-e114-4be6-8770-8fe6447da442",
				"_rev": 6,
				"flow": "5C708489-EE98-4DAC-BC23-C9640CE3C6AE",
				"form_version": "8d9d4f21-f8ed-4a07-9740-76b7acfbd1e8",
				"modified": "2014-01-24T01:52:21.108Z",
				"modified_by": "519978e28e296a2fef000012",
				"created": "2014-01-24T01:52:04.557Z",
				"created_by": "519978e28e296a2fef000012",
				"start_date": "2014-01-24T01:52:21.108Z",
				"steps": [
					{
						"_id": "38DABD60-0385-448E-8B07-66996CD57823",
						"name": "Initiate Request",
						"step_type": "start",
						"deal_type": "",
						"description": "",
						"posx": 29.75,
						"posy": 141,
						"timeout_hours": 168,
						"approver_user_field": "",
						"approver_org_field": "",
						"approver_roles": [],
						"approver_orgs": [],
						"approver_users": [],
						"approver_step": "",
						"fields_modifiable": [],
						"permissions": {
							"__form": "editable",
							"Advance Amount Given": "editable",
							" Travel Details": "editable",
							"Purpose of Travel": "editable",
							"From Date": "editable",
							"To Date": "editable",
							"Claim Details": "editable",
							"Description": "editable",
							"Expense Amount": "editable",
							"Date": "editable",
							"Expense Date": "editable",
							"Expense Type": "editable",
							"Expense Details": "editable",
							"Amount": "editable",
							"Comments": "editable",
							"Total Prepaid by Company": "editable"
						},
						"lines": [
							{
								"_id": "4E2B4C16-1552-4882-A2EC-40E971F81674",
								"name": "",
								"state": "submitted",
								"to_step": "527984b5-a0fc-4e8d-855f-4296dccc0e59",
								"description": ""
							}
						],
						"approver_roles_name": []
					},
					{
						"_id": "527984b5-a0fc-4e8d-855f-4296dccc0e59",
						"name": "Department Manager Approval",
						"step_type": "sign",
						"deal_type": "pickupAtRuntime",
						"description": "",
						"posx": 211,
						"posy": 130,
						"timeout_hours": 168,
						"approver_user_field": "",
						"approver_org_field": "",
						"approver_roles": [],
						"approver_orgs": [],
						"approver_users": [],
						"approver_step": "",
						"fields_modifiable": [],
						"permissions": {},
						"lines": [
							{
								"_id": "13c08b49-5a78-427b-9876-fae82e05190f",
								"name": "",
								"state": "approved",
								"to_step": "545442ba-f9f0-4b29-bebc-e05546fcc601",
								"description": ""
							}
						],
						"approver_roles_name": []
					},
					{
						"_id": "545442ba-f9f0-4b29-bebc-e05546fcc601",
						"name": "General Manager Approval",
						"step_type": "sign",
						"deal_type": "pickupAtRuntime",
						"description": "",
						"posx": 212,
						"posy": 267,
						"timeout_hours": 168,
						"approver_user_field": "",
						"approver_org_field": "",
						"approver_roles": [],
						"approver_orgs": [],
						"approver_users": [],
						"approver_step": "",
						"fields_modifiable": [],
						"permissions": {},
						"lines": [
							{
								"_id": "1deb4126-48ec-4cca-bc8d-e8de2d5c2e46",
								"name": "",
								"state": "approved",
								"to_step": "c0f43a54-e749-4d32-928b-09b981b4f093",
								"description": ""
							}
						],
						"approver_roles_name": []
					},
					{
						"_id": "c0f43a54-e749-4d32-928b-09b981b4f093",
						"name": "Financial Manager Approval",
						"step_type": "sign",
						"deal_type": "pickupAtRuntime",
						"description": "",
						"posx": 213,
						"posy": 414,
						"timeout_hours": 168,
						"approver_user_field": "",
						"approver_org_field": "",
						"approver_roles": [],
						"approver_orgs": [],
						"approver_users": [],
						"approver_step": "",
						"fields_modifiable": [],
						"permissions": {},
						"lines": [
							{
								"_id": "b1b43fac-fabf-447c-b7c6-0812fb19e7a9",
								"name": "",
								"state": "approved",
								"to_step": "36F601E0-5A67-40CD-909A-20466AB823A0",
								"description": ""
							}
						],
						"approver_roles_name": []
					},
					{
						"_id": "36F601E0-5A67-40CD-909A-20466AB823A0",
						"name": "Completed",
						"step_type": "end",
						"deal_type": "",
						"description": "",
						"posx": 424,
						"posy": 424,
						"approver_user_field": "",
						"approver_org_field": "",
						"approver_roles": [],
						"approver_orgs": [],
						"approver_users": [],
						"approver_step": "",
						"fields_modifiable": [],
						"permissions": {},
						"approver_roles_name": []
					}
				]
			},
			"app": "workflow",
			"historys": []
		}
	]
}