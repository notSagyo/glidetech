function init()
  self.multiJumpCount = config.getParameter("multiJumpCount")
  self.multiJumpModifier = config.getParameter("multiJumpModifier")

  refreshJumps()
end

function update(args)
  local jumpActivated = args.moves["jump"] and not self.lastJump
  self.lastJump = args.moves["jump"]
  self.lastLeft = args.moves["left"]
  self.lastRight = args.moves["right"]
  
  updateJumpModifier()
  
  if (self.lastJump and mcontroller.yVelocity() < -20) then
	mcontroller.setYVelocity(-20)

	if self.lastLeft then
		if mcontroller.xVelocity() > 0 then
			mcontroller.setXVelocity(-math.abs(mcontroller.xVelocity() * 0.5))
		end
		mcontroller.setXVelocity(mcontroller.xVelocity() - (3.5 * 0.16))
	end
	if self.lastRight then
		if mcontroller.xVelocity() < 0 then
			mcontroller.setXVelocity(math.abs(mcontroller.xVelocity() * 0.5))
		end
		mcontroller.setXVelocity(mcontroller.xVelocity() + (3.5 * 0.16))
	end
  end
  
  if jumpActivated and canMultiJump() then
    doMultiJump()
  else
    if mcontroller.groundMovement() or mcontroller.liquidMovement() then
      refreshJumps()
    end
  end
end

-- after the original ground jump has finished, start applying the new jump modifier
function updateJumpModifier()
  if self.multiJumpModifier then
    if not self.applyJumpModifier
        and not mcontroller.jumping()
        and not mcontroller.groundMovement() then

      self.applyJumpModifier = true
    end

    if self.applyJumpModifier then mcontroller.controlModifiers({airJumpModifier = self.multiJumpModifier}) end
  end
end

function canMultiJump()
  return self.multiJumps > 0
      and not mcontroller.jumping()
      and not mcontroller.canJump()
      and not mcontroller.liquidMovement()
      and not status.statPositive("activeMovementAbilities")
      and math.abs(world.gravity(mcontroller.position())) > 0
end

function doMultiJump()
  mcontroller.controlJump(true)
  mcontroller.setYVelocity(math.max(0, mcontroller.yVelocity()))
  self.multiJumps = self.multiJumps - 1
  animator.burstParticleEmitter("multiJumpParticles")
  animator.playSound("multiJumpSound")
end

function refreshJumps()
  self.multiJumps = self.multiJumpCount
  self.applyJumpModifier = false
end
