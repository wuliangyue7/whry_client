--
-- Author: Tang
-- Date: 2016-08-09 10:31:00
--炮台
local CannonLayer = class("CannonLayer", cc.Layer)

local module_pre = "game.yule.fishyqs.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_YQSGame"
local Cannon = module_pre..".views.layer.Cannon"
local g_var = ExternalFun.req_var
local CannonSprite = require(module_pre..".views.layer.Cannon")
CannonLayer.enum = 
{

	Tag_userNick =1, 	

	Tag_userScore=2,

	Tag_GameScore = 10,
	Tag_Buttom = 70 ,

	Tag_Cannon = 200,

}

local TAG =  CannonLayer.enum
function CannonLayer:ctor(viewParent)
	
	self.parent = viewParent
	self._dataModel = self.parent._dataModel

	self._gameFrame  = self.parent._gameFrame
	
	--自己信息
	self.m_pUserItem = self._gameFrame:GetMeUserItem()
    self.m_nTableID  = self.m_pUserItem.wTableID
    self.m_nChairID  = self.m_pUserItem.wChairID
    self.m_dwUserID  = self.m_pUserItem.dwUserID

    self.m_cannonList = {} --炮台列表

    self._userList    = {}

    self.rootNode = nil

    self.m_userScore = 0	--用户分数 
    self.m_myCannon = nil
--炮台位置
    self.m_pCannonPos = 
    {
    	cc.p(270,710),
	    cc.p(667,710),
	    cc.p(1082,710),
	    cc.p(270,100),
	    cc.p(667,100),
	    cc.p(1082,100),
	    cc.p(54,399),
	    cc.p(1280,399)
	}

--gun位置
	self.m_GunPlatformPos =
	{

		cc.p(271,742),
		cc.p(667,742),
		cc.p(1082,742),
		cc.p(271,70),
		cc.p(667,70),
		cc.p(1082,70),
		cc.p(14,399),
		cc.p(1320,399)
	}

--用户信息背景
	self.m_NickPos = cc.p(90,14)
	self.m_ScorePos = cc.p(95,45)

	self.myPos = 0			--视图位置


	self:init()

	 --注册事件
    ExternalFun.registerTouchEvent(self,false)
end

function CannonLayer:init()
	
	--加载csb资源
	local csbNode = ExternalFun.loadCSB("game_res/Cannon.csb", self)
    self.rootNode = csbNode

	--初始化自己炮台
	local myCannon = g_var(Cannon):create(self)

	myCannon:initWithUser(self.m_pUserItem)
	myCannon:setPosition(self.m_pCannonPos[myCannon.m_pos + 1])
	self:removeChildByTag(TAG.Tag_Cannon + myCannon.m_pos + 1)
	myCannon:setTag(TAG.Tag_Cannon + myCannon.m_pos + 1)
	self.mypos = myCannon.m_pos + 1
	self:initCannon()
	self:addChild(myCannon)

	--位置提示
	local tipsImage = ccui.ImageView:create("game_res/pos_tips.png")
	tipsImage:setAnchorPoint(cc.p(0.5,0.0))
	tipsImage:setPosition(cc.p(myCannon:getPositionX(),180))
	self:addChild(tipsImage)

	local arrow = ccui.ImageView:create("game_res/pos_arrow.png")
	arrow:setAnchorPoint(cc.p(0.5,0.5))
	arrow:setPosition(cc.p(tipsImage:getContentSize().width/2,-10))
	tipsImage:addChild(arrow)
	local caonnonX = myCannon:getPositionX()

	local jumpUpX = caonnonX
	local jumpUpY = 210

	local jumpDownX = caonnonX
	local jumpDownY = 180
	
	if 6 == self.m_nChairID then
		jumpUpX = 230
		jumpUpY = 371

		jumpDownX = 200
		jumpDownY = 371
		arrow:setPosition(cc.p(-30,tipsImage:getContentSize().height/2))
		arrow:setRotation(90)
	elseif 7 == self.m_nChairID then
		jumpUpX = 1104
		jumpUpY = 371

		jumpDownX = 1134
		jumpDownY = 371
		arrow:setPosition(cc.p(170,tipsImage:getContentSize().height/2))
		arrow:setRotation(270)
	end
	print(string.format("jumpUpX %d jumpUpY %d jumpDownX %d jumpDownY %d", jumpUpX,jumpUpY,jumpDownX,jumpDownY))
	--跳跃动画
	local jumpUP = cc.MoveTo:create(0.4,cc.p(jumpUpX,jumpUpY))
	local jumpDown =  cc.MoveTo:create(0.4,cc.p(jumpDownX,jumpDownY))
	tipsImage:runAction(cc.Repeat:create(cc.Sequence:create(jumpUP,jumpDown), 20))

	tipsImage:runAction(cc.Sequence:create(cc.DelayTime:create(9),cc.CallFunc:create(function (  )
		tipsImage:removeFromParent()
	end)))

	local pos = self.m_nChairID
	pos = CannonSprite.getPos(self._dataModel.m_reversal,pos)
	self:showCannonByChair(pos+1)
	self:initUserInfo(pos+1,self.m_pUserItem)
	
	local cannonInfo ={d=self.m_dwUserID,c=pos+1, cid = self.m_nChairID}
	table.insert(self.m_cannonList,cannonInfo)

	local tMultipleValue = self._dataModel.m_secene.nMultipleValue[1][self._dataModel.m_secene.nMultipleIndex[1][self.m_nChairID + 1] + 1]
	self:updateMultiple(tMultipleValue, pos + 1)
end	

function CannonLayer:showPos()
	--位置提示
	local tipsImage = ccui.ImageView:create("game_res/pos_tips.png")
	tipsImage:setAnchorPoint(cc.p(0.5,0.0))
	tipsImage:setPosition(cc.p(self.m_myCannon:getPositionX(),180))
	self:addChild(tipsImage)

	local arrow = ccui.ImageView:create("game_res/pos_arrow.png")
	arrow:setAnchorPoint(cc.p(0.5,1.0))
	arrow:setPosition(cc.p(tipsImage:getContentSize().width/2,3))
	tipsImage:addChild(arrow)

	local jumpUpX = self.m_myCannon:getPositionX()
	local jumpUpY = 210

	local jumpDownX = self.m_myCannon:getPositionX()
	local jumpDownY = 180
	print(string.format("jumpUpX %d jumpUpY %d jumpDownX %d jumpDownY %d", jumpUpX,jumpUpY,jumpDownX,jumpDownY))
	if 6 == self.m_nChairID then
		jumpUpX = 210
		jumpUpX = self.m_myCannon:getPositionY()

		jumpDownX = 180
		jumpDownY = self.m_myCannon:getPositionY()
	end
	--跳跃动画
	local jumpUP = cc.MoveTo:create(0.4,cc.p(jumpUpX,jumpUpY))
	local jumpDown =  cc.MoveTo:create(0.4,cc.p(jumpDownX,jumpDownY))
	tipsImage:runAction(cc.Repeat:create(cc.Sequence:create(jumpUP,jumpDown), 20))

	tipsImage:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function (  )
		tipsImage:removeFromParent()
	end)))
end


function CannonLayer:initCannon()

	local mypos = self.m_nChairID

	mypos = CannonSprite.getPos(self._dataModel.m_reversal,mypos)

	for i=1,8 do
		if i~= mypos+1 then
			self:HiddenCannonByChair(i)
		end
	end
end


function CannonLayer:initUserInfo(viewpos,userItem)

	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", viewpos))

	if infoBG == nil then
		return
	end
	print("---------------initUserInfo---------------------------",userItem.wChairID,userItem.lScore)
	local nick =  cc.Label:createWithTTF(userItem.szNickName, "fonts/round_body.ttf", 18)
	local scoreNum = cc.Label:createWithCharMap("game_res/scoreNum.png",16,22,string.byte("0"))
	--用户昵称
	local nickPosX = self.m_NickPos.x
	local nickPosY = self.m_NickPos.y

	local scoreX = self.m_ScorePos.x + 8
	local scoreY = self.m_ScorePos.y
	self.m_NickPos = cc.p(78,14)
	self.m_ScorePos = cc.p(95,45)
	if userItem.wChairID >= 6 then
		nickPosX = 120
		nickPosY = 56
		scoreX = 85
		scoreY = 26
		nick:setRotation(180)
		scoreNum:setRotation(180)
	end

	
	nick:setTextColor(cc.WHITE)
	nick:setAnchorPoint(0.5,0.5)
	nick:setTag(TAG.Tag_userNick)
	nick:setPosition(nickPosX, nickPosY)
	infoBG:removeChildByTag(TAG.Tag_userNick)
	infoBG:addChild(nick)

	--用户分数
	if 0 ==  self._dataModel.m_secene.lPlayCurScore[1][userItem.wChairID+1] then
		self._dataModel.m_secene.lPlayCurScore[1][userItem.wChairID+1] = userItem.lScore
	end
	--
	--用户分数
	scoreNum:setString(string.format("%d", userItem.lScore))
	scoreNum:setString(string.format("%d", self._dataModel.m_secene.lPlayCurScore[1][userItem.wChairID+1])) 
	scoreNum:setAnchorPoint(0.5,0.5)
	scoreNum:setTag(TAG.Tag_userScore)
	scoreNum:setPosition(scoreX, scoreY)
	infoBG:removeChildByTag(TAG.Tag_userScore)
	infoBG:addChild(scoreNum)

	if viewpos<4 then
		nick:setRotation(180)
		scoreNum:setRotation(180)
	end

end

function CannonLayer:updateMultiple( mutiple,cannonPos )
	local gunPlatformButtom = self:getChildByTag(TAG.Tag_Buttom+cannonPos)
	local labelMutiple = gunPlatformButtom:getChildByTag(500)
	if nil ~= labelMutiple then
		labelMutiple:setString(string.format("%d", mutiple))
	end
	
end

function CannonLayer:updateUserScore( score,cannonpos )
	
	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", cannonpos))
	if infoBG == nil then
		return
	end
	local scoreLB = infoBG:getChildByTag(TAG.Tag_userScore)
	if score >= 0 and nil ~= scoreLB then
		scoreLB:setString(string.format("%d", score))
	end

	local mypos = self.m_nChairID

	mypos = CannonSprite.getPos(self._dataModel.m_reversal,mypos)

	if mypos == cannonpos - 1 then
		self.parent._gameView:updateUserScore(score)
	end
end


function CannonLayer:HiddenCannonByChair( chair )
	print("隐藏隐藏.........."..chair)

	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", chair))
	infoBG:setVisible(false)

	local gunPlatformCenter = self.rootNode:getChildByName(string.format("gunPlatformCenter_%d", chair))
	gunPlatformCenter:setVisible(false)

	self:removeChildByTag(TAG.Tag_Buttom + chair)

end

function CannonLayer:showCannonByChair( chair , wChairID)

	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", chair))

	if infoBG == nil then
		return
	end

	infoBG:setVisible(true) --玩家信息

	local gunPlatformCenter = self.rootNode:getChildByName(string.format("gunPlatformCenter_%d", chair))
	gunPlatformCenter:setVisible(true)


	local gunPlatformButtom = cc.Sprite:create("game_res/gunPlatformButtom.png")
	gunPlatformButtom:setPosition(self.m_GunPlatformPos[chair].x, self.m_GunPlatformPos[chair].y)
	gunPlatformButtom:setTag(TAG.Tag_Buttom+chair)
	self:removeChildByTag(TAG.Tag_Buttom+chair)
	self:addChild(gunPlatformButtom,5)
	
	--倍数
	local labelMutiple = cc.LabelAtlas:create("1","game_res/mutipleNum.png",14,17,string.byte("0"))
	labelMutiple:setTag(500)
	labelMutiple:setAnchorPoint(0.5,0.5)
	labelMutiple:setPosition(gunPlatformButtom:getContentSize().width/2,22)
	if nil ~= wChairID then
		local tMultipleValue = self._dataModel.m_secene.nMultipleValue[1][self._dataModel.m_secene.nMultipleIndex[1][wChairID + 1] + 1]
		labelMutiple:setString(string.format("%d",tMultipleValue))
	end
	gunPlatformButtom:removeChildByTag(1)
	gunPlatformButtom:addChild(labelMutiple,1)
	print("chair id",chair)
	if chair<4 then
		gunPlatformButtom:setRotation(180)
		gunPlatformButtom:setFlippedX(true)
	
		labelMutiple:setRotation(180)
	elseif chair == 7 then
		gunPlatformButtom:setRotation(90)
	elseif chair == 8 then
		gunPlatformButtom:setRotation(270)
	end
end


function CannonLayer:getCannon(pos)
	
	local cannon = self:getChildByTag(pos + TAG.Tag_Cannon)
	return cannon 

end


function CannonLayer:getCannoByPos( pos )

	local cannon = self:getChildByTag(TAG.Tag_Cannon + pos)
	return  cannon

end


function CannonLayer:getUserIDByCannon(viewid)

	local userid = 0
	if #self.m_cannonList > 0 then
		for i=1,#self.m_cannonList do
			local cannonInfo = self.m_cannonList[i]
			if cannonInfo.c == viewid then
				userid = cannonInfo.d
				break
			end
		end
 	end
	
	 return userid
end

function CannonLayer:onEnter( )
	
end


function CannonLayer:onEnterTransitionFinish(  )

  
end

function CannonLayer:onExit( )

	self.m_cannonList = nil
end

function CannonLayer:onTouchBegan(touch, event)

	if self._dataModel._exchangeSceneing  then 	--切换场景中不能发炮
		return false
	end

	local cannon = self:getCannon(self.mypos)

	if nil ~= cannon then
		local pos = touch:getLocation()

		cannon:shoot(cc.p(pos.x,pos.y), true)

		self.parent:setSecondCount(60)
		
	end

	return true
end

function CannonLayer:onTouchMoved(touch, event)
	
	local cannon = self:getCannon(self.mypos)

	if nil ~= cannon then
		local pos = touch:getLocation()

		cannon:shoot(cc.p(pos.x,pos.y), true)
		self.parent:setSecondCount(60)

	end
end

function CannonLayer:onTouchEnded(touch, event )
	
	local cannon = self:getCannon(self.mypos)

	if nil ~= cannon then
		local pos = touch:getLocation()

		cannon:shoot(cc.p(pos.x,pos.y), false)
		self.parent:setSecondCount(60)
	end
end

--用户进入
function CannonLayer:onEventUserEnter( wTableID,wChairID,useritem )
    print("add user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)

    if wTableID ~= self.m_nTableID or wChairID == self.m_nChairID then
    	return
    end

    local pos = wChairID
    pos = CannonSprite.getPos(self._dataModel.m_reversal,pos)
    print(string.format("-----------------------------onEventUserEnter wChairID %d pos %d score %d---------------------", wChairID,pos,useritem.lScore))
    if pos + 1 == self.m_pos then  --过滤自己
 		return
 	end


    self:showCannonByChair(pos + 1,wChairID)

 	self:removeChildByTag(TAG.Tag_Cannon + pos + 1)

 	if #self.m_cannonList > 0 then
 		for i=1,#self.m_cannonList do
 			local cannonInfo = self.m_cannonList[i]
 			if cannonInfo.d == useritem.dwUserID then
 				table.remove(self.m_cannonList,i)
 				break
 			end
 		end
 	end


 	if #self._userList > 0 then
 		for i=1,#self._userList do
 			local Item = self._userList[i]
 			if Item.dwUserID == useritem.dwUserID then
 				table.remove(self._userList,i)
 				break
 			end
 		end
 	end
 	--self._dataModel.m_secene.lPlayCurScore[1][useritem.wChairID+1] = 0
    local Cannon = g_var(Cannon):create(self)
	Cannon:initWithUser(useritem)
	Cannon:setPosition(self.m_pCannonPos[Cannon.m_pos + 1])
	Cannon:setTag(TAG.Tag_Cannon + Cannon.m_pos + 1)
	self:addChild(Cannon)
	self:initUserInfo(pos + 1,useritem)

	local cannonInfo ={d=useritem.dwUserID,c=pos+1,cid = useritem.wChairID}
	table.insert(self.m_cannonList,cannonInfo)

	table.insert(self._userList, useritem)
end

--用户状态
function CannonLayer:onEventUserStatus(useritem,newstatus,oldstatus)

  		if oldstatus.wTableID ~= self.m_nTableID  then
  			print("不是本桌用户....")
  			return
		end

        if newstatus.cbUserStatus == yl.US_FREE or  newstatus.cbUserStatus == yl.US_NULL then
                
        		if useritem.wChairID ==  self.m_nChairID then
        			self.parent.m_bLeaveGame = true
        			PRELOAD.setEnded(true)
        		end

          	    if #self.m_cannonList > 0 then
          	    	for i=1,#self.m_cannonList do

	          	    	local cannonInfo = self.m_cannonList[i]
	          	    	if cannonInfo.d == useritem.dwUserID then
	          	    		print("用户离开"..cannonInfo.c)
	          	    		self._dataModel.m_secene.lPlayCurScore[1][cannonInfo.cid+1] = 0 
	          	    		self._dataModel.m_secene.nMultipleIndex[1][cannonInfo.cid+1] = 0
	          	    		print("========== self._dataModel.m_secene.lPlayCurScore =========",cannonInfo.cid,self._dataModel.m_secene.lPlayCurScore[1][cannonInfo.cid + 1])
	          	    		--dump(useritem, "the useritem is =============== >", 6)

	          	    		self:HiddenCannonByChair(cannonInfo.c)

	          	    		table.remove(self.m_cannonList,i)

		          	    	if #self._userList > 0 then
						 		for i=1,#self._userList do
						 			local Item = self._userList[i]
						 			if Item.dwUserID == useritem.dwUserID then
						 				table.remove(self._userList,i)
						 				break
						 			end
						 		end
						 	end


	          	    	    local cannon = self:getChildByTag(TAG.Tag_Cannon + cannonInfo.c)
				          	if nil ~= cannon then
				          		print("用户离开 nil ~= cannon")
				          		cannon:removeChildByTag(1000)
					          	cannon:removeTypeTag()
				          	    cannon:removeLockTag()
				          	    cannon:removeFromParent()
				          	end

	          	    	 
	          	    		break
	          	    	end
          	   		 end
          	    end 
        else
        	self._gameFrame:QueryUserInfo( self.m_nTableID,useritem.wChairID)
        	--[[
        		local pos = useritem.wChairID
    			pos = CannonSprite.getPos(self._dataModel.m_reversal,pos)

				if pos + 1 == self.m_pos then  --过滤自己
			 		return
			 	end
          
        		self:showCannonByChair(pos + 1)

        		self:initUserInfo(pos + 1,useritem)
    
    			self:removeChildByTag(TAG.Tag_Cannon + pos + 1)

				if #self.m_cannonList > 0 then
			 		for i=1,#self.m_cannonList do
			 			local cannonInfo = self.m_cannonList[i]
			 			if nil ~= cannonInfo then
			 				if cannonInfo.d == useritem.dwUserID then
			 					table.remove(self.m_cannonList,i)
			 				end
			 			end

			 			
			 		end
		 		end


		 		if #self._userList > 0 then
			 		for i=1,#self._userList do
			 			local Item = self._userList[i]
			 			if Item.dwUserID == useritem.dwUserID then
			 				table.remove(self._userList,i)
			 				break
			 			end
			 		end
			 	end

			 	table.insert(self._userList,useritem)

          	    local Cannon = g_var(Cannon):create(self)
          		Cannon:initWithUser(useritem)
          		Cannon:setPosition(self.m_pCannonPos[pos + 1])
          		Cannon:setTag(TAG.Tag_Cannon + pos + 1)
          		self:addChild(Cannon)
    			
    			local cannonInfo = {d=useritem.dwUserID,c=pos+1,cid = useritem.wChairID}
          		table.insert(self.m_cannonList,cannonInfo)

          		
          		--]]
        end

end

return CannonLayer