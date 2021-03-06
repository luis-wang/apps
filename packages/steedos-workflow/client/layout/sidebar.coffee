Template.workflowSidebar.helpers

	spaceId: ->
		return Steedos.getSpaceId()

	boxName: ->
		if Session.get("box")
			return t(Session.get("box"))

	boxActive: (box)->
		if box == Session.get("box")
			return "active"

	hasInbox: ()->
		query = {}
		query.$or = [{
			inbox_users: Meteor.userId()
		}, {
			cc_users: Meteor.userId()
		}]

		query.space = Session.get("spaceId")

		inboxInstances = db.instances.find(query).fetch();

		return inboxInstances.length > 0

	inboxInstancesFlow: ()->

		inboxInstancesFlow = []

		query = {}
		query.$or = [{
			inbox_users: Meteor.userId()
		}, {
			cc_users: Meteor.userId()
		}]

		query.space = Session.get("spaceId")

		inboxInstances = db.instances.find(query).fetch();

		inboxInstancesGroupByFlow = _.groupBy(inboxInstances, "flow");

		flowIds = _.keys(inboxInstancesGroupByFlow);

		flowIds.forEach (flowId)->
			flow = db.flows.findOne(flowId, {fields:{name:1, space: 1}}) || {name: flowId};
			flow.inbox_count = inboxInstancesGroupByFlow[flowId]?.length;
			inboxInstancesFlow.push(flow)

		return inboxInstancesFlow

	isShowMonitorBox: ()->
		if Meteor.settings.public?.workflow?.onlyFlowAdminsShowMonitorBox
			space = db.spaces.findOne(Session.get("spaceId"))
			if !space
				return false

			if space.admins.includes(Meteor.userId())
				return true
			else
				flow_ids = WorkflowManager.getMyAdminOrMonitorFlows()
				if _.isEmpty(flow_ids)
					return false
				else
					return true

		return true

	draftCount: ()->
		spaceId = Steedos.spaceId()
		userId = Meteor.userId()
		return db.instances.find({state:"draft",space:spaceId,submitter:userId,inbox_users:{$exists:false}}).count()

Template.workflowSidebar.events

	'click .instance_new': (event, template)->
		#判断是否为欠费工作区
		if WorkflowManager.isArrearageSpace()
			toastr.error(t("spaces_isarrearageSpace"))
			return;

		Modal.show("flow_list_box_modal")

	'click .main-header .logo': (event) ->
		Modal.show "app_list_box_modal"

	'click .inbxo-flow': (event, template)->
		Session.set("flowId", this?._id);
