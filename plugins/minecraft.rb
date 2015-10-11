class Minecraft
	include Cinch::Plugin
	include Authentication

	match /minecraft (.+)/i, method: :minecraft
    match /mc (.+)/i, method: :minecraft
    
    def minecraft(m, args)

    end
end