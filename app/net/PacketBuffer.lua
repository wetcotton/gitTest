--
-- Author: xiaopao
-- Date: 2014-09-23 19:27:05
--


local PacketBuffer = class("PacketBuffer")

PacketBuffer.ENDIAN = utilsInit.ByteArrayVarint.ENDIAN_BIG

PacketBuffer.MASK1 = 0x86
PacketBuffer.MASK2 = 0x7b
PacketBuffer.RANDOM_MAX = 10000
PacketBuffer.PACKET_MAX_LEN = 2100000000

PacketBuffer.HEAD_0_LEN = 1
PacketBuffer.HEAD_1_LEN = 1
PacketBuffer.HEAD_2_LEN = 1
PacketBuffer.HEAD_3_LEN = 1
PacketBuffer.PROTO_VERSION_LEN = 1
PacketBuffer.SERVER_VERSION_LEN = 4
PacketBuffer.DATA_TEXT_LEN = 4
PacketBuffer.COMMAND_LEN = 4 

PacketBuffer.STATUS_OK = 1
PacketBuffer.STATUS_INSUFFIENT_DATA = 2
PacketBuffer.STATUS_EXCESS_DATA = 3



PacketBuffer.HEAD_LEN = PacketBuffer.HEAD_0_LEN + PacketBuffer.HEAD_1_LEN + PacketBuffer.HEAD_2_LEN + PacketBuffer.HEAD_3_LEN 
                        + PacketBuffer.PROTO_VERSION_LEN + PacketBuffer.SERVER_VERSION_LEN + PacketBuffer.DATA_TEXT_LEN
                        + PacketBuffer.COMMAND_LEN;

print("-----------PacketBuffer.HEAD_LEN="..PacketBuffer.HEAD_LEN)


function PacketBuffer:ctor()
	self:init()
end

function PacketBuffer:init()
	self.m_str = ""
end

function PacketBuffer:parsePackets(__byteString)
	local __msgs = ""


	self.m_str = self.m_str..__byteString
	
	local body_data_len = 0
	local command_Id = 0 
	local tarStr = ""
	local _next = 1
	local status = 1

	local __preLen = PacketBuffer.HEAD_LEN

	local m_str_len = string.len(self.m_str)

	printf("start analyzing... buffer len: %u, available: %u", m_str_len, m_str_len)

	if m_str_len >= __preLen then

		local HEAD_0,HEAD_1,HEAD_2,HEAD_3,ProtoVersion,ServerVersion

		_next,HEAD_0 = string.unpack(self.m_str,'>A')
		-- print("-------parsePackets next=".._next)
		-- print("-------parsePackets HEAD_0="..HEAD_0)	


		_next,HEAD_1 = string.unpack(self.m_str,'>A',_next)
		-- print("-------parsePackets next=".._next)
		-- print("-------parsePackets HEAD_1="..HEAD_1)	

		_next,HEAD_2 = string.unpack(self.m_str,'>A',_next)
		-- print("-------parsePackets next=".._next)
		-- print("-------parsePackets HEAD_2="..HEAD_2)	

		_next,HEAD_3 = string.unpack(self.m_str,'>A',_next)
		-- print("-------parsePackets next=".._next)
		-- print("-------parsePackets HEAD_3="..HEAD_3)	

		_next,ProtoVersion = string.unpack(self.m_str,'>A',_next)
		-- print("-------parsePackets next=".._next)
		-- print("-------parsePackets ProtoVersion="..ProtoVersion)	

		_next,ServerVersion = string.unpack(self.m_str,'>i',_next)
		-- print("-------parsePackets next=".._next)
		-- print("-------parsePackets ServerVersion="..ServerVersion)	

		_next,body_data_len = string.unpack(self.m_str,'>i',_next)
		-- print("-------parsePackets next=".._next)
		-- print("-------parsePackets body_data_len="..body_data_len)	

		_next,command_Id = string.unpack(self.m_str,'>i',_next)
		-- print("-------parsePackets next=".._next)
		-- print("-------parsePackets command_Id="..command_Id)		

		--printf("body_data_len:%u", body_data_len)
		-- buffer is not enougth
		if ((m_str_len - __preLen) < (body_data_len - 4)) then 
			-- restore the position to the head of data, behind while loop, 
			-- we will save this incomplete buffer in a new buffer,
			-- and wait next parsePackets performation.
			printf("received data is not enough, waiting... need %u, get %u", body_data_len, (body_data_len - 4 - (m_str_len - __preLen)))
			print("buf:"..self.m_str)

			status = PacketBuffer.STATUS_INSUFFIENT_DATA			

		elseif (m_str_len - __preLen) == (body_data_len - 4) then
			if ((body_data_len - 4) <= PacketBuffer.PACKET_MAX_LEN) then

				_next,tarStr = string.unpack(self.m_str,string.format('>A%d', body_data_len-4),_next)

				print("-------onRevData next=".._next)
				--print("-------onRevData tarStr="..tarStr)

				self.m_str = ""

				status = PacketBuffer.STATUS_OK

			end
		else
			print("-------onRevData 粘包")
			if ((body_data_len - 4) <= PacketBuffer.PACKET_MAX_LEN) then

				_next,tarStr = string.unpack(self.m_str,string.format('>A%d', body_data_len-4),_next)

				print("-------onRevData next=".._next)
				print("-------onRevData tarStr="..tarStr)

				status = PacketBuffer.STATUS_EXCESS_DATA

			end
			-- some datas in buffer yet, write them to a new blank buffer.
			local availableStrCnt = m_str_len - (body_data_len - 4 + __preLen)
			printf("cache incomplete buff,len: %u, available: %u", m_str_len, availableStrCnt)
			local __tmp = string.sub(self.m_str, (__preLen + body_data_len - 4 + 1))
			self.m_str = __tmp
			printf("tmp len: %u, availabl: %u",string.len(self.m_str), availableStrCnt)
			print("buf:"..self.m_str)
		end

	end

	return status, command_Id, tarStr
end



return PacketBuffer