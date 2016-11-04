--
-- Author: liufei
-- Date: 2015-03-03 15:13:59
--
GuidePositions = 
{
    --指引第一关
    [10101] = {--点击挑战入口
             guiderPos     = cc.p(display.width*0.45,display.width*0.34),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.63,display.width*0.20),    --指引对话框的坐标
             words         = "跟随红狼开启新的旅程吧。",
             arrowPos      = cc.p(display.width*0.87,display.width*0.01),  --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.764,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
             nextStep      = 10103,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [10103] = {--点击1-1
             guiderPos     = cc.p(display.width*0.54,display.width*0.37),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.38,display.width*0.23),    --指引对话框的坐标
             words         = "人形标识的关卡必须要靠自身的力量通过哦。",
             arrowPos      = cc.p(display.width*0.3,display.width*0.16),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.215,display.height*0.28,display.width*0.12,display.height*0.16),  --高亮的区域
             nextStep      = 10104,
             needReport    = false,                                              --传给服务器的完成标记位
            },
    [10104] = {--点击挑战
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 10105,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [10105] = {--点击战斗按钮开始战斗
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             words         = "",
             arrowPos      = cc.p(display.width*0.96,display.height*0.5+display.width*0.02),    --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.85,display.height*0.5+display.width*0.04,display.width*0.15,display.width*0.07),  --高亮的区域
             nextStep      = 22222,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [10106] = {--结算面板确定
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.85,display.width*0.275),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.8,display.width*0.26,display.width*0.1,display.width*0.1),  --高亮的区域
             nextStep      = 10203,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    

    --指引第二关
    [10201] = {--点击挑战入口
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.87,display.width*0.01),  --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.764,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
             nextStep      = 10203,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    
    [10203] = {--点击1-2
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.3,display.width*0.16),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.215,display.height*0.28,display.width*0.12,display.height*0.16),  --高亮的区域
             nextStep      = 10204,
             needReport    = false,                                              --传给服务器的完成标记位
            },
    [10204] = {--点击挑战
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 10205,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [10205] = {--点击战斗按钮开始战斗
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             words         = "",
             arrowPos      = cc.p(display.width*0.96,display.height*0.5+display.width*0.02),    --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.85,display.height*0.5+display.width*0.04,display.width*0.15,display.width*0.07),  --高亮的区域
             nextStep      = 22222,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [10206] = {--结算面板确定
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.85,display.width*0.275),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.8,display.width*0.26,display.width*0.1,display.width*0.1),  --高亮的区域
             nextStep      = 10207,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10207] = {--返回城镇
             guiderPos     = nil,   --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.18,0),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.06,display.height*0.04,display.width*0.2,display.height*0.095),  --高亮的区域
             nextStep      = 10301,
             needReport    = false,                                          --传给服务器的完成标记位
            },

    -- --指引任务
    [10301] = {--点击任务
             guiderPos     = cc.p(display.width*0.47,display.width*0.44),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.65,display.width*0.30),    --指引对话框的坐标
             words         = "点击这里可以查看新发布的任务和领取奖励哦。",
             arrowPos      = cc.p(display.width*0.97,display.width*0.235),    --指引箭头的坐标
             touchScale    = 1,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.91,display.width*0.245,display.width*0.075,display.height*0.1),  --高亮的区域
             nextStep      = 10302,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [10302] = {--点击领取领取，莫名其妙的遭遇
             guiderPos     = cc.p(display.width*0.3,display.width*0.34),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.48,display.width*0.2),    --指引对话框的坐标
             words         = "你已经打败了怪物，快点击获取奖励吧。",
             arrowPos      = cc.p(display.width*0.65,display.height*0.1),    --指引箭头的坐标
             touchScale    = 1.5,                                            --指引箭头的旋转角度
             promptRect    = cc.rect(display.width*0.57,display.height*0.1,display.width*0.1,display.height*0.09),  --高亮的区域
             nextStep      = 10303,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10303] = {--点击弹出框确定按钮
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.52,display.height*0.24),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.45,display.height*0.3,display.width*0.1,display.height*0.08),  --高亮的区域
             nextStep      = 10304,
             needReport    = true,                                           --传给服务器的完成标记位
            },
    [10304] = {--点击关闭按钮，退出任务
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.92,display.height*0.8),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.86,display.height*0.825,display.width*0.055,display.height*0.093),  --高亮的区域
             nextStep      = 10401,
             needReport    = false,                                           --传给服务器的完成标记位
            },

    --引导上车
    [10401] = {--点击乘降
             guiderPos     = cc.p(display.width*0.21,display.width*0.37),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.38,display.width*0.23),    --指引对话框的坐标
             words         = "在这里可以乘坐你的战车。",
             arrowPos      = cc.p(display.width*0.6,display.width*0.03),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.51,display.width*0.03,display.width*0.09,display.height*0.19),  --高亮的区域
             nextStep      = 10402,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10402] = {--点击选车
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.14,display.width*0.02),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.069,display.width*0.044,display.width*0.105,display.width*0.037),  --高亮的区域
             nextStep      = 10403,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10403] = {--选中第一辆车
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.25,display.width*0.33),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.12,display.width*0.29,display.width*0.21,display.width*0.17),  --高亮的区域
             nextStep      = 10404,
             needReport    = false,                                         --传给服务器的完成标记位
            },
    [10404] = {--点击返回
             guiderPos     = cc.p(display.width*0.40,display.width*0.44),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.28,display.width*0.3),    --指引对话框的坐标
             words         = "快去试试战车的威力吧。",
             arrowPos      = cc.p(display.width*0.055,display.height*0.87),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.004,display.height*0.92,display.width*0.07,display.height*0.07),  --高亮的区域
             nextStep      = 10501,
             needReport    = true,                                       --传给服务器的完成标记位
            },
    
    --指引第一关,装载特种弹
    [10501] = {--战斗入口
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.87,display.width*0.01),  --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.764,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
             nextStep      = 10503,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [10503] = {--1-6
             guiderPos     = cc.p(display.width*0.58,display.width*0.20),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*(0.58-0.17),display.width*0.06),    --指引对话框的坐标
             words         = "小图标上会显示关卡类型哦。",
             arrowPos      = cc.p(display.width*0.76,display.height*0.24),    --指引箭头的坐标
             touchScale    = 1,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.71,display.height*0.27,display.width*0.04,display.height*0.06),  --高亮的区域
             nextStep      = 10504,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [10504] = {--点击挑战
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 10505,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [10505] = {--点击第一个特种弹槽位
             guiderPos     = cc.p(display.width*0.6,display.width*0.27),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.43,display.width*0.12),    --指引对话框的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             words         = "特种弹是战车关卡的好帮手哦。",
             arrowPos      = cc.p(display.width*0.19,display.width*0.36),    --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.11,display.width*0.38,display.width*0.1,display.width*0.05),  --高亮的区域
             nextStep      = 10506,
             needReport    = false,    
              },
    [10506] = {--选中列表中第一个特种弹
             guiderPos     = cc.p(display.width*0.5,display.width*0.40),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.33,display.width*0.25),    --指引对话框的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             words         = "我们来试试装上强酸弹吧。",
             arrowPos      = cc.p(display.width*0.38,display.width*0.385),    --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.31,display.width*0.41,display.width*0.1,display.width*0.05),  --高亮的区域
             nextStep      = 10507,
             needReport    = false,    
             },
    [10507] = {--点击go进入战斗
             guiderPos     = cc.p(display.width*0.46,display.width*0.34),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.63,display.width*0.20),    --指引对话框的坐标
             words         = "强酸弹装填完毕，现在快试试它的威力吧",
             arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 10508,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [10508] = {--引导特种弹释放
             guiderPos     = nil,   --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             touchScale    = 1,                      --点击特效的缩放比例
             words         = "",
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 22222,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [10509] = {--结算面板确定
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.85,display.width*0.275),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.8,display.width*0.26,display.width*0.1,display.width*0.1),  --高亮的区域
             nextStep      = 10510,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10510] = {--返回城镇
             guiderPos     = nil,   --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.18,0),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.06,display.height*0.04,display.width*0.2,display.height*0.095),  --高亮的区域
             nextStep      = 10601,
             needReport    = false,                                          --传给服务器的完成标记位
            },

    --引导抽奖
    [10601] = {--点击抽卡
             guiderPos     = cc.p(display.width*0.75,display.width*0.27),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.6,display.width*0.13),    --指引对话框的坐标
             words         = "对啦，我们镇上的转盘可以去碰碰运气哦。",
             arrowPos      = cc.p(display.width*0.36,display.width*0.03),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.285,display.width*0.03,display.width*0.09,display.width*0.09),  --高亮的区域
             nextStep      = 10602,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10602] = {--点击抽取一个
             guiderPos     = cc.p(display.width*0.23,display.width*0.32),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.4,display.width*0.18),    --指引对话框的坐标
             words         = "每天都有一次免费机会呢，不要错过哦。",
             arrowPos      = cc.p(display.width*0.82,display.height*0.42),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.74,display.height*0.467,display.width*0.11,display.height*0.08),  --高亮的区域
             nextStep      = 10604,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10604] = {--点击返回
             guiderPos     =  cc.p(display.width*0.6 ,display.width*0.28),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      =  cc.p(display.width*(0.6-0.17),display.width*0.14),    --指引对话框的坐标
             words         = "哇，真厉害，是c装置，快给战车装备上吧。",
             arrowPos      = cc.p(display.width*0.06,display.height*0.87),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.01,display.height*0.915,display.width*0.07,display.height*0.07),  --高亮的区域
             nextStep      = 10701,
             needReport    = true,                                       --传给服务器的完成标记位
            },

     --引导战车装备升级
    [10701] = {--改造中心
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.48,display.width*0.03),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.39,display.width*0.03,display.width*0.09,display.height*0.17),  --高亮的区域
             nextStep      = 10702,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10702] = {--点击主炮
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.14,display.width*0.39),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.01,display.width*0.385,display.width*0.234,display.width*0.09),  --高亮的区域
             nextStep      = 10703,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10703] = {--点击弹出框强化按钮
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.41,display.width*0.02),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.344,display.width*0.047,display.width*0.098,display.width*0.04),  --高亮的区域
             nextStep      = 10704,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10704] = {--点击确定强化
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.6,display.width*0.02),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.52,display.width*0.049,display.width*0.118,display.width*0.044),  --高亮的区域
             nextStep      = 10705,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10705] = {--点击关闭，关闭强化面板
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.822,display.width*0.43),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.794,display.width*0.451,display.width*0.055,display.width*0.055),   --高亮的区域
             nextStep      = 10802,
             needReport    = true,                                          --传给服务器的完成标记位
            },

    --引导c装置开孔
    [10801] = {--点击改造中心
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.48,display.width*0.03),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.39,display.width*0.03,display.width*0.09,display.height*0.17),  --高亮的区域
             nextStep      = 10802,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10802] = {--点击c装置槽位
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.14,display.width*0.39),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.01,display.width*0.385,display.width*0.234,display.width*0.09),  --高亮的区域
             nextStep      = 10803,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10803] = {--点击弹出框确定
             guiderPos     = cc.p(display.width*0.82,display.width*0.21),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.67,display.width*0.07),    --指引对话框的坐标
             words         = "装备之前先要开启槽位孔。",
             arrowPos      = cc.p(display.width*0.32,display.width*0.02),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.252,display.width*0.051,display.width*0.098,display.width*0.04),  --高亮的区域
             nextStep      = 10902,
             needReport    = false,       --开孔之后，需要立马手动上传进度，
            },
    --引导装备c装置槽位
    [10901] = {--点击改造中心
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.06,display.height*0.87),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.006,display.height*0.92,display.width*0.07,display.height*0.07),   --高亮的区域
             nextStep      = 10902,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10902] = {--点击Ｃ装置槽位
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.06,display.height*0.87),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.006,display.height*0.92,display.width*0.07,display.height*0.07),   --高亮的区域
             nextStep      = 10903,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [10903] = {--点击更换
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.06,display.height*0.87),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.006,display.height*0.92,display.width*0.07,display.height*0.07),   --高亮的区域
             nextStep      = 11002,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    --引导激活技能
    [11001] = {--改造中心
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.48,display.width*0.03),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.39,display.width*0.03,display.width*0.09,display.height*0.17),  --高亮的区域
             nextStep      = 11002,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11002] = {--点击专属技能
             guiderPos     = cc.p(display.width*0.85,display.width*0.34),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*(0.85-0.17),display.width*0.20),    --指引对话框的坐标
             words         = "每辆战车都有4个专属技能，在战斗中消耗能量进行施放。",
             arrowPos      = cc.p(display.width*0.52,display.width*0.11),    --指引箭头的坐标
             touchScale    = 1,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.45,display.width*0.13,display.width*0.1,display.height*0.03),  --高亮的区域
             nextStep      = 11003,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11003] = {--点击弹道卫星
             guiderPos     = cc.p(display.width*0.44,display.width*0.27),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.6,display.width*0.13),    --指引对话框的坐标
             words         = "当装备上的星数达到一定条件后就可以激活技能了哦",
             arrowPos      = cc.p(display.width*0.66,display.width*0.35),    --指引箭头的坐标
             touchScale    = 1.2,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.6,display.width*0.37,display.width*0.1,display.height*0.03),  --高亮的区域
             nextStep      = 11004,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11004] = {--弹出框，点击确定
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.415,display.width*0.18),    --指引箭头的坐标
             touchScale    = 1.2,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.355,display.width*0.2,display.width*0.1,display.height*0.03),  --高亮的区域
             nextStep      = 11005,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11005] = {--点击关闭，关闭技能面板
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.75,display.width*0.45),    --指引箭头的坐标
             touchScale    = 1.2,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.69,display.width*0.46,display.width*0.04,display.width*0.04),  --高亮的区域
             nextStep      = 11006,
             needReport    = true,                                          --传给服务器的完成标记位
            },
    [11006] = {--点击返回主界面
             guiderPos     = cc.p(display.width*0.5,display.width*0.45),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.33,display.width*0.30),    --指引对话框的坐标
             words         = "快去试试技能在战斗中的效果吧",
             arrowPos      = cc.p(display.width*0.06,display.height*0.87),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.01,display.height*0.915,display.width*0.07,display.height*0.07),  --高亮的区域
             nextStep      = 11101,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    
    --指引第四关
    [11101] = {--点击挑战入口
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.87,display.width*0.01),  --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.764,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
             nextStep      = 11103,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [11102] = {--点击大区
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.22,display.width*0.38),   --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.07,display.height*0.65,display.width*0.25,display.height*0.22), --高亮的区域
             nextStep      = 11103,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11103] = {--点击1-3
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.3,display.width*0.16),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.215,display.height*0.28,display.width*0.12,display.height*0.16),  --高亮的区域
             nextStep      = 11104,
             needReport    = false,                                              --传给服务器的完成标记位
            },
    [11104] = {--点击挑战
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 11105,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [11105] = {--点击战斗按钮开始战斗
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             words         = "",
             arrowPos      = cc.p(display.width*0.96,display.height*0.5+display.width*0.02),    --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.85,display.height*0.5+display.width*0.04,display.width*0.15,display.width*0.07),  --高亮的区域
             nextStep      = 22222,
             needReport    = false,                                             --传给服务器的完成标记位
            },
--战斗完成后，除了上报关卡信息外，还要手动将nextStep赋值为11009
    [11109] = {--结算面板确定
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.18,0),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.06,display.height*0.04,display.width*0.2,display.height*0.095),  --高亮的区域
             nextStep      = 11110,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11110] = {--返回城镇
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.18,0),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.06,display.height*0.04,display.width*0.2,display.height*0.095),  --高亮的区域
             nextStep      = 11201,
             needReport    = false,                                          --传给服务器的完成标记位
            },


    [11201] = {--赏金首
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.87,display.width*0.01),  --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.764,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
             nextStep      = 11202,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [11202] = {--第一个怪
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.22,display.width*0.38),   --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.07,display.height*0.65,display.width*0.25,display.height*0.22), --高亮的区域
             nextStep      = 11203,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11203] = {--点击前往
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,
             touchScale    = 1.5,                      --点击特效的缩放比例
             words         = "",
             arrowPos      = cc.p(display.width*0.55,display.width*0.32),   --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.45,display.height*0.53,display.width*0.12,display.height*0.17),  --高亮的区域
             nextStep      = 11204,
             needReport    = false,                                           --传给服务器的完成标记位
          },
    [11204] = {--点击水怪关卡
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 11205,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [11205] = {--点击水怪关卡
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 11206,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [11206] = {--点击牵引位1
                     guiderPos     = cc.p(display.width*0.8,display.width*0.27),   --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.7,display.width*0.13),
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     words         = "点击这里可以租用公车或军团成员的车辅助战斗哦。",
                     arrowPos      = cc.p(display.width*0.4,display.height*0.08),    --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.375,display.height*0.08,display.width*0.05,display.width*0.05),  --高亮的区域
                     nextStep      = 11208,
                     needReport    = false,                                             --传给服务器的完成标记位
                    },
    [11207] = {--点击租车tab
	     guiderPos     = cc.p(display.width*0.7,display.width*0.37),   --指引者头像的坐标
         guiderX       = 1,--指引者头像的朝向  1右向  2左向
         wordsPos      = cc.p(display.width*0.6,display.width*0.23),
	     touchScale    = 1.5,                      --点击特效的缩放比例
	     words         = "这里是租赁中心，你可以在这租借公用战车或军团成员的战车。",
	     arrowPos      = cc.p(display.width*0.96,display.height*0.5+display.width*0.02),    --指引箭头的坐标
	     promptRect    = cc.rect(display.width*0.85,display.height*0.5+display.width*0.04,display.width*0.15,display.width*0.07),  --高亮的区域
	     nextStep      = 11208,
	     needReport    = false,                                             --传给服务器的完成标记位
    },
    [11208] = {--点击第一辆车
		--选择要租的战车
	     guiderPos     = cc.p(display.width*0.6,display.width*0.27),   --指引者头像的坐标
         guiderX       = -1,--指引者头像的朝向  1右向  2左向
         wordsPos      = cc.p(display.width*0.5,display.width*0.13),
	     touchScale    = 1.5,                      --点击特效的缩放比例
	     words         = "租用吉普车去挑战水怪吧。",
	     arrowPos      = cc.p(display.width*0.16,display.height*0.64),    --指引箭头的坐标
	     promptRect    = cc.rect(display.width*0.13,display.height*0.6,display.width*0.1,display.width*0.1),  --高亮的区域
	     nextStep      = 11209,
	     needReport    = false,                                             --传给服务器的完成标记位
    },

    [11209] = {--点击go进入战斗
		--点击go进入战斗
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.96,display.height*0.5+display.width*0.02),    --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.85,display.height*0.5+display.width*0.04,display.width*0.15,display.width*0.07),  --高亮的区域
                     nextStep      = 11210,
                     needReport    = false,                                             --传给服务器的完成标记位
                    },
    [11210] = {--弹出面板，点击确定
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.96,display.height*0.5+display.width*0.02),    --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.85,display.height*0.5+display.width*0.04,display.width*0.15,display.width*0.07),  --高亮的区域
                     nextStep      = 22222,
                     needReport    = false,                                             --传给服务器的完成标记位
                    },
    [11211] = {--结算面板确定
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.85,display.width*0.275),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.8,display.width*0.26,display.width*0.1,display.width*0.1),  --高亮的区域
             nextStep      = 11303,
             needReport    = false,                                          --传给服务器的完成标记位
            },

    -- --指引第六关，镜片
    [11301] = {--点击战斗入口
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             touchScale    = 1.5,                       --点击特效的缩放比例
             words         = "",
             arrowPos      = cc.p(display.width*0.87,display.width*0.01),  --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.764,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
             nextStep      = 11303,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [11303] = {--点击1-6
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.19,display.height*0.38),    --指引箭头的坐标
             touchScale    = 0.8,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.148,display.height*0.42,display.width*0.04,display.height*0.06),  --高亮的区域
             nextStep      = 11304,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [11304] = {--点击挑战按钮进入布阵
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 11305,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [11305] = {--点击右拉框，拉起激光炮选择面板
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             words         = "",
             arrowPos      = cc.p(display.width*0.96,display.height*0.5+display.width*0.02),    --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.85,display.height*0.5+display.width*0.04,display.width*0.15,display.width*0.07),  --高亮的区域
             nextStep      = 11306,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [11306] = {--选中第一个镜片
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.85,display.width*0.275),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.8,display.width*0.26,display.width*0.1,display.width*0.1),  --高亮的区域
             nextStep      = 11307,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11307] = {--点击go
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.85,display.width*0.275),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.8,display.width*0.26,display.width*0.1,display.width*0.1),  --高亮的区域
             nextStep      = 11308,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11308] = {--点击释放激光炮
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.85,display.width*0.275),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.8,display.width*0.26,display.width*0.1,display.width*0.1),  --高亮的区域
             nextStep      = 22222,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11309] = {--计算面板，点击确定
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.85,display.width*0.275),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.8,display.width*0.26,display.width*0.1,display.width*0.1),  --高亮的区域
             nextStep      = 11310,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11310] = {--点击返回城镇
             guiderPos     = nil,   --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.18,0),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.06,display.height*0.04,display.width*0.2,display.height*0.095),  --高亮的区域
             nextStep      = 11401,
             needReport    = false,                                          --传给服务器的完成标记位
            },

    --指引人物装备升级
    [11401] = {--点击属性按钮
             guiderPos     = cc.p(display.width*0.6,display.width*0.24),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.5,display.width*0.10),    --指引对话框的坐标
             words         = "是不是觉得打起来有点吃力了呢，去强化一下装备吧。",
             arrowPos      = cc.p(display.width*0.13,display.width*0.02),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.055,display.width*0.02,display.width*0.09,display.width*0.1),  --高亮的区域
             nextStep      = 11402,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11402] = {--点击武器，弹弓
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.22,display.width*0.34),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.127,display.width*0.339,display.width*0.09,display.width*0.09),  --高亮的区域
             nextStep      = 11403,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11403] = {--点击升级按钮
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.65,0),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.561,display.width*0.028,display.width*0.13,display.width*0.04),  --高亮的区域
             nextStep      = 11503,
             needReport    = false,                                         --传给服务器的完成标记位
            },

    --指引人物装备升级
    [11501] = {--点击属性按钮
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.13,display.width*0.02),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.055,display.width*0.02,display.width*0.09,display.width*0.1),  --高亮的区域
             nextStep      = 11502,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11502] = {--点击武器，弹弓
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.22,display.width*0.34),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.127,display.width*0.339,display.width*0.09,display.width*0.09),  --高亮的区域
             nextStep      = 11503,
             needReport    = false,                                          --传给服务器的完成标记位
            },
   
    [11503] = {--点击一键升级按钮
             guiderPos     =  cc.p(display.width*0.32,display.width*0.23),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      =  cc.p(display.width*0.47,display.width*0.11),    --指引对话框的坐标
             words         = "点击这里可以进行一键强化哦。",
             arrowPos      = cc.p(display.width*0.895,display.width*0.398),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.853,display.width*0.433,display.width*0.045,display.width*0.045),  --高亮的区域
             nextStep      = 11504,
             needReport    = false,
            },
    [11504] = {
             guiderPos     =  cc.p(display.width*0.5 ,display.width*0.44),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      =  cc.p(display.width*(0.5-0.17),display.width*0.30),    --指引对话框的坐标
             words         = "人物所有的装备都可以进行强化哦",
             arrowPos      = cc.p(display.width*0.895,display.width*0.398),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.853,display.width*0.433,display.width*0.045,display.width*0.045),  --高亮的区域
             nextStep      = 11601,
             needReport    = true,
            },
    --指引第七关
    [11601] = {--点击挑战入口
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.87,display.width*0.01),  --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.764,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
             nextStep      = 11603,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [11602] = {--点击大区
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.22,display.width*0.38),   --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.07,display.height*0.65,display.width*0.25,display.height*0.22), --高亮的区域
             nextStep      = 11603,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11603] = {--点击1-7
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.3,display.width*0.16),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.215,display.height*0.28,display.width*0.12,display.height*0.16),  --高亮的区域
             nextStep      = 11604,
             needReport    = false,                                              --传给服务器的完成标记位
            },
    [11604] = {--点击挑战
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 11605,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [11605] = {--点击战斗按钮开始战斗
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             words         = "",
             arrowPos      = cc.p(display.width*0.96,display.height*0.5+display.width*0.02),    --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.85,display.height*0.5+display.width*0.04,display.width*0.15,display.width*0.07),  --高亮的区域
             nextStep      = 22222,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [11606] = {--结算面板确定
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.85,display.width*0.275),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.8,display.width*0.26,display.width*0.1,display.width*0.1),  --高亮的区域
             nextStep      = 11703,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    --指引第二大区第一关
    [11701] = {--点击挑战入口
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.87,display.width*0.01),  --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.764,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
             nextStep      = 11703,
             needReport    = false,                                            --传给服务器的完成标记位
            },
    [11702] = {--点击大区
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.22,display.width*0.38),   --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.07,display.height*0.65,display.width*0.25,display.height*0.22), --高亮的区域
             nextStep      = 11703,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [11703] = {--点击1-7
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.3,display.width*0.16),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.215,display.height*0.28,display.width*0.12,display.height*0.16),  --高亮的区域
             nextStep      = 11704,
             needReport    = false,                                              --传给服务器的完成标记位
            },
    [11704] = {--点击挑战
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
             nextStep      = 11705,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    [11705] = {--点击战斗按钮开始战斗
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             words         = "",
             arrowPos      = cc.p(display.width*0.96,display.height*0.5+display.width*0.02),    --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.85,display.height*0.5+display.width*0.04,display.width*0.15,display.width*0.07),  --高亮的区域
             nextStep      = 22222,
             needReport    = false,                                             --传给服务器的完成标记位
            },
    

    --10级开启
    [12101] = {--点击属性
                     guiderPos     = cc.p(display.width*0.65,display.width*0.22),  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.48,display.width*0.07),    --指引对话框的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     words         = "人物也会解锁新技能哦",
                     arrowPos      = cc.p(display.width*0.12,display.width*0.04),   --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.045,display.height*0.06,display.width*0.1,display.width*0.1),  --高亮的区域
                     nextStep      = 12102,
                     needReport    = false,                                            --传给服务器的完成标记位
          },
    [12102] = {--点击技能tab
                     --说明：技能分页闪烁，点击进入，
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     words         = "",
                     arrowPos      = cc.p(display.width*0.81,display.height*0.82),    --指引箭头的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     promptRect    = cc.rect(display.width*0.78,display.height*0.82,display.width*0.06,display.width*0.04),  --高亮的区域
                     nextStep      = 12103,
                     needReport    = false,                                            --传给服务器的完成标记位
            },
    [12103] = {--过期的参丸
                     --说明：点击加号，技能升级
                     guiderPos     = cc.p(display.width*0.33,display.height*0.73),  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.5,display.height*0.46),    --指引对话框的坐标
                     words         = "人物的技能可以升级，不要忘了哦",
                     arrowPos      = cc.p(display.width*0.82,display.height*0.60),    --指引箭头的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     promptRect    = cc.rect(display.width*0.79,display.height*0.60,display.width*0.06,display.width*0.04),  --高亮的区域
                     nextStep      = 12104,
                     needReport    = false,                                            --传给服务器的完成标记位
            },
    [12104] = {--点击关闭
                     --说明：点击关闭
                     guiderPos     = cc.p(display.width*0.28,display.height*0.75),  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.32,display.height*0.48),
                     words         = "消耗技能点进行升级，每次升级都会获得一定技能点。",
                     arrowPos      = cc.p(display.width*0.89,display.height*0.76),    --指引箭头的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     promptRect    = cc.rect(display.width*0.85,display.height*0.76,display.width*0.05,display.width*0.05),  --高亮的区域
                     nextStep      = 12201,
                     needReport    = true,                                           --传给服务器的完成标记位
            },
    --12级开启
     [12201] = {--点击任务
                     --说明：任务按钮闪烁，成就任务闪烁，点击进入成就
                     guiderPos     = cc.p(display.width*0.43,display.height*0.43),  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.6,display.height*0.26),    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "哇，你已经十二级了哦，去看看任务那里有没有奖励吧。",
                     arrowPos      = cc.p(display.width*0.96,display.height*0.45),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.91,display.height*0.43,display.width*0.07,display.width*0.07),  --高亮的区域
                     nextStep      = 12202,
                     needReport    = false,                                          --传给服务器的完成标记位
                  },
     
     [12202] = {--点击领取
                     --说明：战队12级成就，点击领取
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.65,display.height*0.1),    --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.57,display.height*0.1,display.width*0.1,display.height*0.09),  --高亮的区域
                     nextStep      = 12203,
                     needReport    = false,                                          --传给服务器的完成标记位
                  },
     [12203] = {--点击确定
                     --说明：点击确认，关闭收获物品对话框
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.51,display.height*0.3),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.45,display.height*0.3,display.width*0.1,display.width*0.04),  --高亮的区域
                     nextStep      = 12204,
                     needReport    = true,                                          --传给服务器的完成标记位
                  },
     [12204] = {
                     --说明：点击关闭
                     guiderPos     = cc.p(display.width*0.72,display.width*0.50),  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.55,display.width*0.35),    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "不错哦，这些装备碎片可以合成一件很好的装备哦。",
                     arrowPos      = cc.p(display.width*0.943,display.height*0.845),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.918,display.height*0.832,display.width*0.05,display.width*0.05),  --高亮的区域
                     nextStep      = 12401,
                     needReport    = false,                                          --传给服务器的完成标记位
                  },
     [12301] = {
                     --说明：点击背包，进去合成引擎碎片
                     guiderPos     = cc.p(display.width*0.65,display.width*0.27),  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.48,display.width*0.12),    --指引对话框的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     words         = "碎片数量足够时可以在背包中进行合成。",
                     arrowPos      = cc.p(display.width*0.22,display.width*0.04),   --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.16,display.height*0.05,display.width*0.1,display.width*0.1),  --高亮的区域
                     nextStep      = 12302,
                     needReport    = false,                                             --传给服务器的完成标记位
                  },
     [12302] = {
                     --说明：点击战车装备
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.44,display.height*0.8),   --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.38,display.height*0.76,display.width*0.1,display.width*0.1),  --高亮的区域
                     nextStep      = 12303,
                     needReport    = false,                                             --传给服务器的完成标记位
                  },
     [12303] = {
                     --说明：点击引擎分页
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.46,display.height*0.64),   --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.39,display.height*0.6,display.width*0.1,display.width*0.1),  --高亮的区域
                     nextStep      = 12304,
                     needReport    = false,                                             --传给服务器的完成标记位
                  },
     [12304] = {
                     --说明：点击第一项，弹出合成面板
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.3,display.height*0.46),   --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.24,display.height*0.42,display.width*0.1,display.width*0.1),  --高亮的区域
                     nextStep      = 12305,
                     needReport    = false,                                             --传给服务器的完成标记位
                  },
     [12305] = {
                     --说明：点击合成
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.43,display.height*0.09),   --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.36,display.height*0.05,display.width*0.1,display.width*0.1),  --高亮的区域
                     nextStep      = 12306,
                     needReport    = false,                                             --传给服务器的完成标记位
                  },
     [12306] = {
                    --说明：点击关闭背包
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     words         = "",
                     arrowPos      = cc.p(display.width*0.92,display.height*0.74),    --指引箭头的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     promptRect    = cc.rect(display.width*0.88,display.height*0.74,display.width*0.05,display.width*0.05),  --高亮的区域
                     nextStep      = 12401,
                     needReport    = true,                                       --传给服务器的完成标记位
                  },
    --14级开启
     [12401] = {
                     --说明：去打精英副本
                     guiderPos     = cc.p(display.width*0.23,display.height*0.43),  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.4,display.height*0.16),    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "精英副本开启了，居然有强化后的怪物来到了拉多村，我们去消灭它们",
                     arrowPos      = cc.p(display.width*0.87,display.width*0.01),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.764,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
                     nextStep      = 12403,
                     needReport    = false,                                          --传给服务器的完成标记位
          },
     [12402] = {--点击大地图
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     words         = "",
                     arrowPos      = cc.p(display.width*0.22,display.width*0.4),   --指引箭头的坐标
                     touchScale    = 1.5,  
                     promptRect    = cc.rect(display.width*0.07,display.height*0.65,display.width*0.25,display.height*0.22),  --高亮的区域
                     nextStep      = 12403,
                     needReport    = false,                                            --传给服务器的完成标记位
          },
     [12403] = {--点击精英按钮
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     words         = "",
                     arrowPos      = cc.p(display.width*0.22,display.width*0.4),   --指引箭头的坐标
                     touchScale    = 1.5,  
                     promptRect    = cc.rect(display.width*0.07,display.height*0.65,display.width*0.25,display.height*0.22),  --高亮的区域
                     nextStep      = 12501,
                     needReport    = false,     --手动上传进度
                     },
        --15级开启
     [12501] = {
                     --说明：改造中心，觉醒
                     guiderPos     = cc.p(display.width*0.85,display.width*0.34),  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.7,display.width*0.2),    --指引对话框的坐标
                     words         = "战车会与人物一同成长，只有你变得强大后才能恢复原来的样子，咱们去试试吧。",
                     arrowPos      = cc.p(display.width*0.46,display.width*0.03),    --指引箭头的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     promptRect    = cc.rect(display.width*0.388,display.width*0.03,display.width*0.09,display.width*0.09),  --高亮的区域
                     nextStep      = 12502,
                     needReport    = false,                                          --传给服务器的完成标记位
                    },
     [12502] = {
                     --说明：点击觉醒按钮
                     guiderPos     = cc.p(display.width*0.85,display.width*0.34),  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.7,display.width*0.2),    --指引对话框的坐标
                     words         = "就是这里，进行改造。",
                     arrowPos      = cc.p(display.width*0.51,display.width*0.057),    --指引箭头的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     promptRect    = cc.rect(display.width*0.45,display.width*0.058,display.width*0.08,display.width*0.04),  --高亮的区域
                     nextStep      = 12601,
                     needReport    = false,                                          --传给服务器的完成标记位
                    },
     [12503] = {
                     --说明：点击确认，花费金币觉醒
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = -1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     words         = "",
                     arrowPos      = cc.p(display.width*0.5,display.height*0.085),    --指引箭头的坐标
                     touchScale    = 1.5,                      --点击特效的缩放比例
                     promptRect    = cc.rect(display.width*0.455,display.height*0.09,display.width*0.08,display.width*0.04),  --高亮的区域
                     nextStep      = 12504,
                     needReport    = false,                                          --传给服务器的完成标记位
                    },
     [12504] = {
                     --说明：退回到主界面
                     guiderPos     = cc.p(display.width*0.19,display.height*0.43),  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.36,display.height*0.16),
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "好帅，以后还会更加炫酷哦，有没有一点小期待呀。",
                     arrowPos      = cc.p(display.width*0.1,display.height*0.9),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.0,display.height*0.9,display.width*0.08,display.width*0.08),  --高亮的区域
                     nextStep      = 12601,
                     needReport    = true,                                          --传给服务器的完成标记位
                  },
        --16级开启
    [12601] = {
                     --说明：点击进入竞技场
                     guiderPos     = cc.p(display.width*0.15,display.height*0.48),  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.32,display.height*0.21),    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "现在你已经有了足够的实力，去镇子上的竞技场试试吧。",
                     arrowPos      = cc.p(display.width*0.34,display.width*0.36),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.28,display.width*0.32,display.width*0.12,display.width*0.12),  --高亮的区域
                     nextStep      = 12701,
                     needReport    = false,    --手动上传进度
          },
    
        --20级开启
    [12701] = {
                     --说明：城镇，勇士中心
                     guiderPos     = cc.p(display.width*0.19,display.height*0.46),  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.36,display.height*0.19),    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "听说最近勇士中心有遗迹任务，可以获得大量的金币和材料哦。",
                     arrowPos      = cc.p(display.width*0.66,display.width*0.36),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.61,display.width*0.32,display.width*0.12,display.width*0.12),  --高亮的区域
                     nextStep      = 12703,
                     needReport    = false,     
          },
    [12703] = {
                     --说明：遗迹探测
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.66,display.width*0.36),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.61,display.width*0.32,display.width*0.12,display.width*0.12),  --高亮的区域
                     nextStep      = 12801,
                     needReport    = false,         --需要手动上传
          },
        --25级开启
    [12801] = {
                     --说明：城镇，勇士中心
                     guiderPos     = cc.p(display.width*0.19,display.height*0.43),  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.36,display.height*0.16),    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "现在你已经小有名气了，明奇博士在勇士中心的时光机那有话跟你说，去看看吧。",
                     arrowPos      = cc.p(display.width*0.66,display.width*0.36),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.61,display.width*0.32,display.width*0.12,display.width*0.12),  --高亮的区域
                     nextStep      = 12803,
                     needReport    = false,     
          },
    [12803] = {
                     --远征
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.66,display.width*0.36),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.61,display.width*0.32,display.width*0.12,display.width*0.12),  --高亮的区域
                     nextStep      = 12901,
                     needReport    = false,         --需要手动上传
          },
   --28级开启
    [12901] = {
                     --说明：这一步只是弹出善恶选择框
                     guiderPos     = nil,  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = nil,    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "",
                     arrowPos      = cc.p(display.width*0.68,display.height*0.42),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.61,display.height*0.38,display.width*0.12,display.width*0.12),  --高亮的区域
                     nextStep      = 13001,
                     needReport    = false,        --需要手动上传
          },
    [13001] = {
                     --说明：军团
                     guiderPos     = cc.p(display.width*0.19,display.height*0.43),  --指引者头像的坐标
                     guiderX       = 1,--指引者头像的朝向  1右向  2左向
                     wordsPos      = cc.p(display.width*0.36,display.height*0.16),    --指引对话框的坐标
                     touchScale    = 1.5,                       --点击特效的缩放比例
                     words         = "军团招新啦。快去看看有没有合适的军团加入吧",
                     arrowPos      = cc.p(display.width*0.68,display.height*0.42),  --指引箭头的坐标
                     promptRect    = cc.rect(display.width*0.61,display.height*0.38,display.width*0.12,display.width*0.12),  --高亮的区域
                     nextStep      = 13101,
                     needReport    = false,        --需要手动上传
          },
--[==[
************************************************************************************
以下是条件引导
************************************************************************************
]==]
    [20101] = {--打完第九关后，返回城镇
             guiderPos     = nil,   --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,
             words         = "",
             arrowPos      = cc.p(display.width*0.18,0),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.06,display.height*0.04,display.width*0.2,display.height*0.095),  --高亮的区域
             nextStep      = 20201,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    --指引人物装备进阶
    [20201] = {--点击属性按钮
             guiderPos     = cc.p(display.width*0.7,display.width*0.31),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.6,display.width*0.17),    --指引对话框的坐标
             words         = "告诉你个好消息，姐姐攒够了零花钱准备给你换个好点的武器。",
             arrowPos      = cc.p(display.width*0.13,display.width*0.02),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.055,display.width*0.02,display.width*0.09,display.width*0.1),  --高亮的区域
             nextStep      = 20202,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [20202] = {--点击武器，弹弓
             guiderPos     = cc.p(display.width*0.7,display.width*0.31),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.6,display.width*0.17),    --指引对话框的坐标
             words         = "现在可以把你的弹弓进阶啦。",
             arrowPos      = cc.p(display.width*0.22,display.width*0.34),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.127,display.width*0.339,display.width*0.09,display.width*0.09),  --高亮的区域
             nextStep      = 20203,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    [20203] = {--点击进阶按钮
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             words         = "",
             arrowPos      = cc.p(display.width*0.65,0),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.561,display.width*0.028,display.width*0.13,display.width*0.04),  --高亮的区域
             nextStep      = 20204,
             needReport    = false,                                         --传给服务器的完成标记位
            },
    [20204] = {
             guiderPos     =  cc.p(display.width*0.42,display.width*0.43),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      =  cc.p(display.width*0.57,display.width*0.31),    --指引对话框的坐标
             words         = "哈哈，装备变强了，等所有的装备都达到顶级时就可以换装了哦。",
             arrowPos      = cc.p(display.width*0.895,display.width*0.398),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.853,display.width*0.433,display.width*0.045,display.width*0.045),  --高亮的区域
             nextStep      = 0,
             needReport    = false,
            },
    [20301] = {--打完精英1-5后，返回城镇
             guiderPos     = nil,   --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,
             words         = "",
             arrowPos      = cc.p(display.width*0.18,0),    --指引箭头的坐标
             touchScale    = 1.5,                      --点击特效的缩放比例
             promptRect    = cc.rect(display.width*0.06,display.height*0.04,display.width*0.2,display.height*0.095),  --高亮的区域
             nextStep      = 20401,
             needReport    = false,                                          --传给服务器的完成标记位
            },
    --捉拿赏金首
    [20401] = {--说明：进入通缉令
             --
             guiderPos     = cc.p(display.width*0.47,display.width*0.44),  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.65,display.width*0.30),    --指引对话框的坐标
             touchScale    = 1.5,                       --点击特效的缩放比例
             words         = "对了，我们去打听打听有没有什么新奇的消息。",
             arrowPos      = cc.p(display.width*0.75,display.width*0.01),  --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.644,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
             nextStep      = 20402,
             needReport    = false,                                         --传给服务器的完成标记位
          },
    [20402] = {--点击水鬼
             --
             guiderPos     = nil,  --指引者头像的坐标
             guiderX       = 1,--指引者头像的朝向  1右向  2左向
             wordsPos      = nil,    --指引对话框的坐标
             touchScale    = 1.5,                       --点击特效的缩放比例
             words         = "",
             arrowPos      = cc.p(display.width*0.50,display.width*0.34),  --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.445,display.width*0.32,display.width*0.12,display.width*0.12),  --高亮的区域
             nextStep      = 20403,
             needReport    = false,                                          --传给服务器的完成标记位
          },
    [20403] = {--点击前往
             --
             guiderPos     = cc.p(display.width*0.65,display.height*0.70),  --指引者头像的坐标
             guiderX       = -1,--指引者头像的朝向  1右向  2左向
             wordsPos      = cc.p(display.width*0.50,display.height*0.47),    --指引对话框的坐标
             touchScale    = 1.5,                       --点击特效的缩放比例
             words         = "在这里可以看到这个城镇的赏金首哦",
             arrowPos      = cc.p(display.width*0.43,display.width*0.4),  --指引箭头的坐标
             promptRect    = cc.rect(display.width*0.30,display.width*0.36,display.width*0.12,display.width*0.12),  --高亮的区域
             nextStep      = 11112,
             needReport    = false,                                          --传给服务器的完成标记位
          },
    -- [20404] = {--点击精英1-8
    --          guiderPos     = cc.p(display.width*0.65,display.width*0.27),  --指引者头像的坐标
    --          guiderX       = -1,--指引者头像的朝向  1右向  2左向
    --          wordsPos      = cc.p(display.width*0.48,display.width*0.12),
    --          touchScale    = 1.5,                      --点击特效的缩放比例
    --          words         = "我们现在就去捉拿赏金首吧",
    --          arrowPos      = cc.p(display.width*0.55,display.width*0.32),   --指引箭头的坐标
    --          promptRect    = cc.rect(display.width*0.45,display.height*0.53,display.width*0.12,display.height*0.17),  --高亮的区域
    --          nextStep      = 11111,  --此处放开，打完赏金首了自动跳到20406
    --          needReport    = false,                                           --传给服务器的完成标记位
    --       },
    -- [20405] = {--点击挑战
    --          guiderPos     = nil,  --指引者头像的坐标
    --          guiderX       = 1,--指引者头像的朝向  1右向  2左向
    --          wordsPos      = nil,    --指引对话框的坐标
    --          words         = "",
    --          arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
    --          touchScale    = 1.5,                      --点击特效的缩放比例
    --          promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
    --          nextStep      = 11111,
    --          needReport    = false,                                            --传给服务器的完成标记位
    --         },
    -- [20406] = {--返回城镇
    --          guiderPos     = nil,  --指引者头像的坐标
    --          guiderX       = 1,--指引者头像的朝向  1右向  2左向
    --          wordsPos      = nil,    --指引对话框的坐标
    --          words         = "",
    --          arrowPos      = cc.p(display.width*0.78,display.height*0.5-display.width*0.2),    --指引箭头的坐标
    --          touchScale    = 1.5,                      --点击特效的缩放比例
    --          promptRect    = cc.rect(display.width*0.7,display.height*0.5-display.width*0.19,display.width*0.12,display.width*0.04),  --高亮的区域
    --          nextStep      = 20503,
    --          needReport    = false,                                            --传给服务器的完成标记位
    --         },
    -- --领取赏金首
    -- [20501] = {--进入通缉令
    --          --说明：
    --          guiderPos     = nil,  --指引者头像的坐标
    --          guiderX       = 1,--指引者头像的朝向  1右向  2左向
    --          wordsPos      = nil,    --指引对话框的坐标
    --          touchScale    = 1.5,                       --点击特效的缩放比例
    --          words         = "",
    --          arrowPos      = cc.p(display.width*0.75,display.width*0.01),  --指引箭头的坐标
    --          promptRect    = cc.rect(display.width*0.644,-display.width*0.01,display.width*0.145,display.width*0.145),  --高亮的区域
    --          nextStep      = 20502,
    --          needReport    = false,                                         --传给服务器的完成标记位
    --       },
    -- [20502] = {--点击水怪
    --          --说明：
    --          guiderPos     = nil,  --指引者头像的坐标
    --          guiderX       = 1,--指引者头像的朝向  1右向  2左向
    --          wordsPos      = nil,    --指引对话框的坐标
    --          touchScale    = 1.5,                       --点击特效的缩放比例
    --          words         = "",
    --          arrowPos      = cc.p(display.width*0.50,display.width*0.34),  --指引箭头的坐标
    --          promptRect    = cc.rect(display.width*0.445,display.width*0.32,display.width*0.12,display.width*0.12),  --高亮的区域
    --          nextStep      = 20503,
    --          needReport    = false,                                          --传给服务器的完成标记位
    --       },
    -- [20503] = {--点击领取
    --          --
    --          guiderPos     = nil,  --指引者头像的坐标
    --          guiderX       = -1,--指引者头像的朝向  1右向  2左向
    --          wordsPos      = nil,    --指引对话框的坐标
    --          touchScale    = 1.5,                       --点击特效的缩放比例
    --          words         = "",
    --          arrowPos      = cc.p(display.width*0.43,display.width*0.4),  --指引箭头的坐标
    --          promptRect    = cc.rect(display.width*0.30,display.width*0.36,display.width*0.12,display.width*0.12),  --高亮的区域
    --          nextStep      = 20504,
    --          needReport    = false,                                          --传给服务器的完成标记位
    --       },
    -- [20504] = {--第一次点击关闭
    --          --说明：
    --          guiderPos     = nil,  --指引者头像的坐标
    --          guiderX       = -1,--指引者头像的朝向  1右向  2左向
    --          wordsPos      = nil,    --指引对话框的坐标
    --          touchScale    = 1.5,                       --点击特效的缩放比例
    --          words         = "",
    --          arrowPos      = cc.p(display.width*0.1,display.height*0.9),  --指引箭头的坐标
    --          promptRect    = cc.rect(display.width*0.0,display.height*0.9,display.width*0.08,display.width*0.08),  --高亮的区域
    --          nextStep      = 20505,
    --          needReport    = false,      --因为这里会被removeguidelayer,所以在这里上传
    --       },
    -- [20505] = {--第二次点击关闭，退回到主界面
    --          --说明：
    --          guiderPos     = nil,  --指引者头像的坐标
    --          guiderX       = -1,--指引者头像的朝向  1右向  2左向
    --          wordsPos      = nil,    --指引对话框的坐标
    --          touchScale    = 1.5,                       --点击特效的缩放比例
    --          words         = "",
    --          arrowPos      = cc.p(display.width*0.1,display.height*0.9),  --指引箭头的坐标
    --          promptRect    = cc.rect(display.width*0.0,display.height*0.9,display.width*0.08,display.width*0.08),  --高亮的区域
    --          nextStep      = 0,
    --          needReport    = false,                                          --传给服务器的完成标记位
    --       },
}