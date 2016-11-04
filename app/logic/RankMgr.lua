--
-- Author: Jun Jiang
-- Date: 2015-01-15 18:59:13
--

--排行榜类型
RANK_TYPE_PVE_STRENGTH 	= 1
RANK_TYPE_PVP 			= 2
RANK_TYPE_ARMY_GOOD 	= 3
RANK_TYPE_ARMY_EVIL 	= 4
RANK_TYPE_GOOD 			= 5
RANK_TYPE_EVIL 			= 6

RankMgr = class("RankMgr")
RankMgr.srv_RankInfo = nil
RankMgr.nCurRankType = RANK_TYPE_PVE_STRENGTH

function RankMgr:ReqRankInfo(nType)
    startLoading()
	self.nCurRankType = nType
	local tabMsg = {characterId=srv_userInfo.characterId, type=nType}
	m_socket:SendRequest(json.encode(tabMsg), CMD_RANK_GETRANK,  RankMgr, RankMgr.OnRankInfoRet)
end

function RankMgr:OnRankInfoRet(cmd)
	if 1==cmd.result then
		self.srv_RankInfo = cmd.data
	else
		showTips(cmd.msg)
		printInfo("RankMgr:ReqRankInfo failed! nCurRankType=%d  result=%d", self.nCurRankType, cmd.result)
	end

    if nil~=rankLayer.Instance then
        rankLayer.Instance:OnRankInfoRet(cmd)
    end
end