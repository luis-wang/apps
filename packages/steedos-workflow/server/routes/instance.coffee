Cookies = Npm.require("cookies")

getInstanceReadOnly = (req, res, next, options) ->
#	获取客户端请求IP
	clientIp = req.headers['x-forwarded-for'] or req.connection.remoteAddress or req.socket.remoteAddress or req.connection.socket.remoteAddress
#	获取白名单
	whitelist = Meteor.settings.whitelist

	user = Steedos.getAPILoginUser(req, res)

	spaceId = req.params.space

	instanceId = req.params.instance_id

	instance = db.instances.findOne({_id: instanceId});

	space = db.spaces.findOne({_id: spaceId});

	if !space
		JsonRoutes.sendResult res,
			code: 401,
			data:
				"error": "Validate Request -- Missing space",
				"success": false
		return;

	if  !instance
		JsonRoutes.sendResult res,
			code: 401,
			data:
				"error": "Validate Request -- Missing instance",
				"success": false
		return;

	if !user
		if clientIp && whitelist && _.isArray(whitelist) && _.indexOf(whitelist, clientIp) > -1
			user = db.users.findOne({_id: space.owner})
		else
			if !user
				JsonRoutes.sendResult res,
					code: 401,
					data:
						"error": "Validate Request -- Missing X-Auth-Token,X-User-Id",
						"success": false
				return;

	if instance.space != spaceId
		JsonRoutes.sendResult res,
			code: 401,
			data:
				"error": "Validate Request -- Missing space or instance",
				"success": false
		return;



	spaceUser = db.space_users.findOne({user: user._id, space: spaceId});

	if !spaceUser
		if !space
			JsonRoutes.sendResult res,
				code: 401,
				data:
					"error": "Validate Request -- Missing sapceUser",
					"success": false
			return;
	#校验user是否对instance有查看权限
	if !WorkflowManager.hasInstancePermissions(user, instance)
		JsonRoutes.sendResult res,
			code: 401,
			data:
				"error": "Validate Request -- Not Instance Permissions",
				"success": false
		return;

	html = InstanceReadOnlyTemplate.getInstanceHtml(user, space, instance, options)
	dataBuf = new Buffer(html);
	res.setHeader('content-length', dataBuf.length)
	res.setHeader('content-range', "bytes 0-#{dataBuf.length - 1}/#{dataBuf.length}")
	res.statusCode = 200
	res.end(html)

JsonRoutes.add "get", "/workflow/space/:space/view/readonly/:instance_id", getInstanceReadOnly

JsonRoutes.add "get", "/workflow/space/:space/view/readonly/:instance_id/:instance_name", (req, res, next)->
	res.setHeader('Content-type', 'application/x-msdownload');
	res.setHeader('Content-Disposition', 'attachment;filename='+encodeURI(req.params.instance_name));
	res.setHeader('Transfer-Encoding', '')

	options = {absolute: true}

	return getInstanceReadOnly(req, res, next, options)

JsonRoutes.add "get", "/api/workflow/instances", (req, res, next) ->

	user = Steedos.getAPILoginUser(req, res)

	if !user
		JsonRoutes.sendResult res,
			code: 401,
			data:
				"error": "Validate Request -- Missing X-Auth-Token,X-User-Id",
				"success": false
		return;

	spaceId = req.headers["x-space-id"]

	if not spaceId
		JsonRoutes.sendResult res,
			code: 401,
			data:
				"error": "Validate Request -- Missing X-Space-Id",
				"success": false
		return;

	flowId = req.query?.flowId

	if !flowId
		JsonRoutes.sendResult res,
			code: 400,
			data:
				"error": "Validate Request -- Missing flowId",
				"success": false
		return;

	query = {}

	ret_sync_token = new Date().getTime()

	flowIds = flowId.split(",")


	flows = db.flows.find({_id: {$in: flowIds}}).fetch()

	i = 0
	while i < flows.length
		f = flows[i]
		spaceUser = db.space_users.findOne({space: f.space, user: user._id})
		if !spaceUser
			JsonRoutes.sendResult res,
				code: 401,
				data:
					"error": "Validate Request -- No permission, flow is #{f._id}",
					"success": false
			return;
		else

	#	是否工作区管理员
		if !Steedos.isSpaceAdmin(spaceId, user._id)
			spaceUserOrganizations = db.organizations.find({
				_id: {
					$in: spaceUser.organizations
				}
			}).fetch();

			if !WorkflowManager.canMonitor(f, spaceUser, spaceUserOrganizations) && !WorkflowManager.canAdmin(f, spaceUser, spaceUserOrganizations)
				JsonRoutes.sendResult res,
					code: 401,
					data:
						"error": "Validate Request -- No permission, flow is #{f._id}",
						"success": false
				return;
		i++


	query.flow = {$in: flowIds}

	query.space = spaceId

	if req.query?.sync_token
		sync_token = new Date(Number(req.query.sync_token))
		query.modified = {$gt: sync_token}

	query.final_decision = {$ne: "terminated"}

	if req.query?.state
		query.state = {$in: req.query.state.split(",")}
	else
		query.state = "completed"

#	最多返回500条数据
	instances = db.instances.find query, {fields: {inbox_uers: 0, cc_users: 0, outbox_users: 0, traces: 0}, skip: 0, limit: 500}

	JsonRoutes.sendResult res,
			code: 200,
			data:
				"status": "success",
				"sync_token": ret_sync_token
				"data": instances.fetch()
	return;
