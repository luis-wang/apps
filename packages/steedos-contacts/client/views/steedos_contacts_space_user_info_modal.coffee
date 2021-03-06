Template.steedos_contacts_space_user_info_modal.helpers
	spaceUserName: ->
		spaceUser = db.space_users.findOne this.targetId;
		return spaceUser.name;

	spaceUserEmail: ->
		spaceUser = db.space_users.findOne this.targetId;
		return spaceUser.email;

	spaceUserMobile: ->
		mobile = "";
		spaceUser = db.space_users.findOne this.targetId;
		if spaceUser.mobile
			mobile = spaceUser.mobile
		return mobile;
	
	spaceUserWorkPhone: ->
		workPhone = "";
		spaceUser = db.space_users.findOne this.targetId;
		if spaceUser.work_phone
			workPhone = spaceUser.work_phone
		return workPhone;
	
	spaceUserPosition: ->
		Position = "";
		spaceUser = db.space_users.findOne this.targetId;
		if spaceUser.position
			Position = spaceUser.position
		return Position;
	
	spaceUserOrganizations: ->
		spaceUser = db.space_users.findOne this.targetId;
		if spaceUser
			return SteedosDataManager.organizationRemote.find({_id: {$in: spaceUser.organizations}},{fields: {fullname: 1}})
		return []

	spaceUserInfo: ->
		info = ""
		spaceUser = db.space_users.findOne this.targetId, {fields: {name: 1, email: 1, position: 1, mobile: 1, work_phone: 1, organizations: 1}};
		if spaceUser
			orgArray = SteedosDataManager.organizationRemote.find({_id: {$in: spaceUser.organizations}},{fields: {fullname: 1}})
			if orgArray
				userInfo = []
				orgFullname = ""
				orgArray.forEach (org)->
					orgFullname = org.fullname + "\r\n               " + orgFullname
				# 定义复制信息的样式
				userInfo.push("#{t('steedos_contacts_name')}:#{spaceUser.name}")
				userInfo.push("#{t('steedos_contacts_email')}:#{if spaceUser.email then spaceUser.email else ""}")
				userInfo.push("#{t('steedos_contacts_position')}:#{if spaceUser.position then spaceUser.position else ""}")
				userInfo.push("#{t('steedos_contacts_mobile')}:#{if spaceUser.mobile then spaceUser.mobile else ""}")
				userInfo.push("#{t('steedos_contacts_work_phone')}:#{if spaceUser.work_phone then spaceUser.work_phone else ""}")
				userInfo.push("#{t('steedos_contacts_organizations')}:#{orgFullname}")
				
				info = userInfo.join('\n')
		
		return info

Template.steedos_contacts_space_user_info_modal.events
	'click .steedos-info-close': (event,template) ->
		Modal.hide('steedos_contacts_space_user_info_modal')


Template.steedos_contacts_space_user_info_modal.onRendered ()->
	copyInfoClipboard = new Clipboard('.steedos-info-copy', text: (spaceUser) ->
		return spaceUser.dataset.info
	)

	Template.steedos_contacts_space_user_info_modal.copyInfoClipboard = copyInfoClipboard
	
	copyInfoClipboard.on 'success', (e) ->
		e.clearSelection()
		toastr.success t("steedos_contacts_copy_successfully")
		return
	copyInfoClipboard.on 'error', (e) ->
		toastr.error t("steedos_contacts_copy_failed")
		return

Template.steedos_contacts_space_user_info_modal.onDestroyed ->
	Template.steedos_contacts_space_user_info_modal.copyInfoClipboard.destroy()