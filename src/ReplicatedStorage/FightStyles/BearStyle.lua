local BearStyle = {}

BearStyle.description = "A two-handed sword style with an offensive lean. All techniques are hard-hitting," +
    "imposing the user's might and melee prowess into every swing, stab, and block."

BearStyle.animations = {
    FrontAttack = "rbxassetid://13906940328",
    BackAttack = "rbxassetid://13928264676",
    Idle = "rbxassetid://13906933290",
    Move = "rbxassetid://13906935601"
}

BearStyle.FrontAttack = {
    comboReq = 0,
    keysReq = {"W","-"},
    Activate = function(user)
        
    end
}

return BearStyle