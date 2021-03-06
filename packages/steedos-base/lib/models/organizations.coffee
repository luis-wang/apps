db.organizations = new Meteor.Collection('organizations')


db.organizations._simpleSchema = new SimpleSchema
	space: 
		type: String,
		optional: true,
		autoform: 
			type: "hidden",
			defaultValue: ->
				return Session.get("spaceId");
	name:
		type: String,
		max: 200
	admins: 
		type: [String],
		optional: true,
		autoform:
			type: ->
				return if Steedos.isSpaceAdmin() then "selectuser" else "hidden"
			multiple: true
	parent:
		type: String,
		optional: true,
		autoform:
			type: "selectorg"
	sort_no: 
		type: Number
		optional: true
		defaultValue: 100
		autoform: 
			defaultValue: 100
	users: 
		type: [String],
		optional: true,
		autoform: 
			type: "selectuser"
			multiple: true
	is_company: 
		type: Boolean,
		optional: true,
		autoform: 
			omit: true
	parents: 
		type: [String],
		optional: true,
		autoform: 
			omit: true
	fullname: 
		type: String,
		optional: true,
		autoform: 
			omit: true
	children:
		type: [String],
		optional: true,
		autoform: 
			omit: true
	created:
		type: Date,
		optional: true
	created_by:
		type: String,
		optional: true
	modified:
		type: Date,
		optional: true
	modified_by:
		type: String,
		optional: true
	hidden:
		type: Boolean,
		optional: true,
		autoform:
			defaultValue: false

if Meteor.isClient
	db.organizations._simpleSchema.i18n("organizations")
	db.organizations._sortFunction = (doc1, doc2) ->
		if (doc1.sort_no == doc2.sort_no)
			return doc1.name?.localeCompare(doc2.name); 
		else if (doc1.sort_no > doc2.sort_no)
			return -1
		else
			return 1

db.organizations.attachSchema db.organizations._simpleSchema;


db.organizations.helpers

	calculateParents: ->
		parents = [];
		if (!this.parent)
			return parents
		parentId = this.parent;
		while (parentId)
			parents.push(parentId)
			parentOrg = db.organizations.findOne({_id: parentId}, {parent: 1, name: 1});
			if (parentOrg)
				parentId = parentOrg.parent
			else
				parentId = null
		return parents


	calculateFullname: ->
		fullname = this.name;
		if (!this.parent)
			return fullname;
		parentId = this.parent;
		while (parentId)
			parentOrg = db.organizations.findOne({_id: parentId}, {parent: 1, name: 1});
			fullname = parentOrg?.name + "/" + fullname;
			if (parentOrg)
				parentId = parentOrg.parent
			else
				parentId = null
		return fullname


	calculateChildren: ->
		children = []
		childrenObjs = db.organizations.find({parent: this._id}, {fields: {_id:1}});
		childrenObjs.forEach (child) ->
			children.push(child._id);
		return children;

	updateUsers: ->
		users = []
		spaceUsers = db.space_users.find({organizations: this._id}, {fields: {user:1}});
		spaceUsers.forEach (user) ->
			users.push(user.user);
		db.organizations.direct.update({_id: this._id}, {$set: {users: users}})

	space_name: ->
		space = db.spaces.findOne({_id: this.space});
		return space?.name

	users_count: ->
		if this.users
			return this.users.length
		else 
			return 0

	calculateAllChildren: ->
		children = []
		childrenObjs = db.organizations.find({parents: {$in:[this._id]}}, {fields: {_id:1}})
		childrenObjs.forEach (child) ->
			children.push(child._id);
		return _.uniq children

	calculateUsers: (isIncludeParents)->
		orgs = if isIncludeParents then this.calculateAllChildren() else this.calculateChildren()
		orgs.push(this._id)
		users = []
		userOrgs = db.organizations.find({_id:{$in:orgs}}, {fields: {users:1}})
		userOrgs.forEach (org)->
			if org?.users?.length
				users = users.concat org.users
		return _.uniq users


if (Meteor.isServer) 

	db.organizations.before.insert (userId, doc) ->
		doc.created_by = userId;
		doc.created = new Date();
		doc.modified_by = userId;
		doc.modified = new Date();
		#doc.is_company = !doc.parent;
		if (!doc.space)
			throw new Meteor.Error(400, "organizations_error_space_required");
		# check space exists
		space = db.spaces.findOne(doc.space)
		if !space
			throw new Meteor.Error(400, "organizations_error_space_not_found");

		# only space admin or org admin can insert organizations
		if space.admins.indexOf(userId) < 0
			isOrgAdmin = false
			if doc.parent
				parentOrg = db.organizations.findOne(doc.parent)
				parents = parentOrg?.parents
				if parents
					parents.push(doc.parent)
				else
					parents = [doc.parent]
				if db.organizations.findOne({_id:{$in:parents}, admins:{$in:[userId]}})
					isOrgAdmin = true
			else if doc.is_company == true
				# 注册用户的时候会触发"before.insert"，且其userId为underfined，所以这里需要通过is_company来判断是否是新注册用户时进该函数。
				isOrgAdmin = true
			unless isOrgAdmin
				throw new Meteor.Error(400, "organizations_error_org_admins_only")

		# if doc.users
		# 	throw new Meteor.Error(400, "organizations_error_users_readonly");

		# 同一个space中不能有同名的organization，parent 不能有同名的 child
		if doc.parent
			parentOrg = if parentOrg then parentOrg else db.organizations.findOne(doc.parent)
			if parentOrg.children
				nameOrg = db.organizations.find({_id: {$in: parentOrg.children}, name: doc.name}).count()
				if nameOrg>0
					throw new Meteor.Error(400, "organizations_error_organizations_name_exists") 
		else
			# 新增部门时不允许创建根部门
			broexisted = db.organizations.find({space:doc.space}).count()
			if broexisted > 0
				throw new Meteor.Error(400, "organizations_error_organizations_parent_required")

			orgexisted = db.organizations.find({name: doc.name, space: doc.space,fullname:doc.name}).count()				
			if orgexisted > 0
				throw new Meteor.Error(400, "organizations_error_organizations_name_exists")

		# only space admin can update organization.admins
		if space.admins.indexOf(userId) < 0
			if (doc.admins)
				throw new Meteor.Error(400, "organizations_error_space_admins_only_for_org_admins");
		

	db.organizations.after.insert (userId, doc) ->
		updateFields = {}
		obj = db.organizations.findOne(doc._id)
		
		updateFields.parents = obj.calculateParents();
		updateFields.fullname = obj.calculateFullname()

		if !_.isEmpty(updateFields)
			db.organizations.direct.update(obj._id, {$set: updateFields})

		if doc.parent
			parent = db.organizations.findOne(doc.parent)
			db.organizations.direct.update(parent._id, {$set: {children: parent.calculateChildren()}});
		if doc.users
			space_users = db.space_users.find({space: doc.space, user: {$in: doc.users}}).fetch()
			_.each space_users, (su)->
				orgs = su.organizations
				orgs.push(doc._id)
				db.space_users.direct.update({_id: su._id}, {$set: {organizations: orgs}})

		# 新增部门后在audit_logs表中添加一条记录
		insertedDoc = db.organizations.findOne({_id: doc._id})
		sUser = db.space_users.findOne({space: doc.space, user: userId},{fields: {name: 1}})
		if sUser
			db.audit_logs.insert
				c_name: "organizations",
				c_action: "add",
				object_id: doc._id,
				object_name: doc.name,
				value_previous: null,
				value: JSON.parse(JSON.stringify(insertedDoc)),
				created_by: userId,
				created_by_name: sUser.name,
				created: new Date()


	db.organizations.before.update (userId, doc, fieldNames, modifier, options) ->
		modifier.$set = modifier.$set || {};
		# check space exists
		space = db.spaces.findOne(doc.space)
		if !space
			throw new Meteor.Error(400, "organizations_error_space_not_found");

		# only space admin or org admin can update organizations
		if space.admins.indexOf(userId) < 0
			isOrgAdmin = false
			if doc.admins?.includes userId
				isOrgAdmin = true
			else if doc.parent
				parents = doc.parents
				if db.organizations.findOne({_id:{$in:parents}, admins:{$in:[userId]}})
					isOrgAdmin = true
			unless isOrgAdmin
				throw new Meteor.Error(400, "organizations_error_org_admins_only")

		if (modifier.$set.space and doc.space!=modifier.$set.space)
			throw new Meteor.Error(400, "organizations_error_space_readonly");

		if (modifier.$set.parents)
			throw new Meteor.Error(400, "organizations_error_parents_readonly");

		if (modifier.$set.children)
			throw new Meteor.Error(400, "organizations_error_children_readonly");

		if (modifier.$set.fullname)
			throw new Meteor.Error(400, "organizations_error_fullname_readonly");

		# only space admin can update organization.admins
		if space.admins.indexOf(userId) < 0
			if (typeof doc.admins != typeof modifier.$set.admins or doc.admins?.sort().join(",") != modifier.$set.admins?.sort().join(","))
				throw new Meteor.Error(400, "organizations_error_space_admins_only_for_org_admins");

		modifier.$set.modified_by = userId;
		modifier.$set.modified = new Date();

		# if modifier.$set.users
		# 	throw new Meteor.Error(400, "organizations_error_users_readonly");
								
		if (modifier.$set.parent)
			# parent 不能等于自己或者 children
			parentOrg = db.organizations.findOne({_id: modifier.$set.parent})
			if (doc._id == parentOrg._id || parentOrg.parents.indexOf(doc._id)>=0)
				throw new Meteor.Error(400, "organizations_error_parent_is_self")
			# 同一个 parent 不能有同名的 child
			if parentOrg.children
				nameOrg = db.organizations.find({_id: {$in: parentOrg.children}, name: modifier.$set.name}).count()
				if (nameOrg > 0 ) && (modifier.$set.name != doc.name)
					throw new Meteor.Error(400, "organizations_error_organizations_name_exists")
				
		# else if (modifier.$set.name != doc.name)					
		# 	existed = db.organizations.find({name: modifier.$set.name, space: doc.space,fullname:modifier.$set.name}).count()				
		# 	if existed > 0
		# 		throw new Meteor.Error(400, "organizations_error.organizations_name_exists"))

		# 根部门名字无法修改
		if modifier.$set.name != doc.name && (doc.is_company == true)
			throw new Meteor.Error(400, "organizations_error_organization_is_company")
		

	db.organizations.after.update (userId, doc, fieldNames, modifier, options) ->
		updateFields = {}
		obj = db.organizations.findOne(doc._id)
		if obj.parent
			updateFields.parents = obj.calculateParents();
		# 更新上级部门的children
		if (modifier.$set.parent)
			newParent = db.organizations.findOne(doc.parent)
			db.organizations.direct.update(newParent._id, {$set: {children: newParent.calculateChildren()}});
			# 如果更改 parent，更改前的对象需要重新生成children
			oldParent = db.organizations.find({children:doc._id});
			oldParent.forEach (organization) ->
				existed = db.organizations.find({_id:doc._id,parent:organization._id}).count()
				if (existed == 0)
					db.organizations.direct.update({_id:organization._id},{$pull:{children:doc._id}})


		# 如果更改 parent 或 name, 需要更新 自己和孩子们的 fullname	
		if (modifier.$set.parent || modifier.$set.name)
			updateFields.fullname = obj.calculateFullname()
			children = db.organizations.find({parents: doc._id});
			children.forEach (child) ->
				db.organizations.direct.update(child._id, {$set: {fullname: child.calculateFullname()}})

		if !_.isEmpty(updateFields)
			db.organizations.direct.update(obj._id, {$set: updateFields})

		old_users = this.previous.users || []
		new_users = modifier.$set.users || []
		added_users = _.difference(new_users, old_users)
		removed_users = _.difference(old_users, new_users)
		if added_users.length > 0
			added_space_users = db.space_users.find({space: doc.space, user: {$in: added_users}}).fetch()
			_.each added_space_users, (su)->
				orgs = su.organizations
				orgs.push(doc._id)
				db.space_users.direct.update({_id: su._id}, {$set: {organizations: orgs}})
		if removed_users.length > 0
			removed_space_users = db.space_users.find({space: doc.space, user: {$in: removed_users}}).fetch()
			root_org = db.organizations.findOne({space: doc.space, is_company: true}, {fields: {_id: 1}})
			_.each removed_space_users, (su)->
				orgs = su.organizations
				if orgs.length is 1
					db.space_users.direct.update({_id: su._id}, {$set: {organizations: [root_org._id], organization: root_org._id}})
				else if orgs.length > 1
					new_orgs = _.filter(orgs, (org_id)->
						return org_id isnt doc._id
					)
					if su.organization is doc._id
						db.space_users.direct.update({_id: su._id}, {$set: {organizations: new_orgs, organization: new_orgs[0]}})
					else
						db.space_users.direct.update({_id: su._id}, {$set: {organizations: new_orgs}})


		# 更新部门后在audit_logs表中添加一条记录
		updatedDoc = db.organizations.findOne({_id: doc._id})
		sUser = db.space_users.findOne({space: doc.space, user: userId},{fields:{name:1}})
		if sUser
			db.audit_logs.insert
				c_name: "organizations",
				c_action: "edit",
				object_id: doc._id,
				object_name: doc.name,
				value_previous: this.previous,
				value: JSON.parse(JSON.stringify(updatedDoc)),
				created_by: userId,
				created_by_name: sUser.name,
				created: new Date()

	
	db.organizations.before.remove (userId, doc) ->
		# check space exists
		space = db.spaces.findOne(doc.space)
		if !space
			throw new Meteor.Error(400, "organizations_error_space_not_found");

		# only space admin or org admin can remove organizations
		if space.admins.indexOf(userId) < 0
			isOrgAdmin = false
			if doc.admins?.includes userId
				isOrgAdmin = true
			else if doc.parent
				parents = doc.parents
				if db.organizations.findOne({_id:{$in:parents}, admins:{$in:[userId]}})
					isOrgAdmin = true
			unless isOrgAdmin
				throw new Meteor.Error(400, "organizations_error_org_admins_only")

		# can not delete organization with children
		if (doc.children && doc.children.length>0)
			throw new Meteor.Error(400, "organizations_error_organization_has_children");

		# can not delete organization with users
		if (doc.users && doc.users.length > 0)
			throw new Meteor.Error(400, "organizations_error_organization_has_users");

		if (doc.is_company)
			throw new Meteor.Error(400, "organizations_error_can_not_remove_root_organization");


	db.organizations.after.remove (userId, doc) ->
		if (doc.parent)
			parent = db.organizations.findOne(doc.parent)
			db.organizations.direct.update(parent._id, {$set: {children: parent.calculateChildren()}});

		# !!! If delete organization, a lot of data need delete.
		# if doc.users
		#	_.each doc.users, (userId) ->
		#		db.space_users.direct.update({user: userId}, {$unset: {organization: 1}})

		# 删除部门后在audit_logs表中添加一条记录
		sUser = db.space_users.findOne({space: doc.space, user: userId},{fields:{name:1}})
		if sUser
			db.audit_logs.insert
				c_name: "organizations",
				c_action: "delete",
				object_id: doc._id,
				object_name: doc.name,
				value_previous: doc,
				value: null,
				created_by: userId,
				created_by_name: sUser.name,
				created: new Date()
	
	Meteor.publish 'organizations', (spaceId)->
		
		unless this.userId
			return this.ready()
		
		unless spaceId
			return this.ready()

		user = db.users.findOne(this.userId);

		selector = 
			space: spaceId


		return db.organizations.find(selector)

	Meteor.publish 'my_organizations', (spaceId)->
		
		unless this.userId
			return this.ready()
		
		unless spaceId
			return this.ready()


		return db.organizations.find({space: spaceId, users: this.userId})
