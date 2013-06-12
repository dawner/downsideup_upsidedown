import UnityEngine

class Shoot (MonoBehaviour): 
	# public bullet as GameObject
	# public bulletSpeed as single  = 1000F
	public followDistance as single = 10
	public shootDistance as single = 5
	public lazer as GameObject
	public speed as single = 2.0

	private target as GameObject

	#state variables
	private SHOOTER as bool =false
	private SEEKING as bool =false 
	private PATROL as bool =true 
	private HIT as bool =false 

	private shootTime as single = 0
	private shootDir as Vector3 = Vector3(-1,0,0)
	private direction as single = -1
	private hitTime as single = 0

	def setHit(isHit as bool):
		HIT = isHit

	def Start ():
        target = GetComponent(CollisionDeath).target
        

	def Update ():
		if (LayerMask.NameToLayer("Top World") == gameObject.layer) and (LayerMask.NameToLayer("Top World") == target.layer) and (target.renderer.enabled):
			inSameWorld = true
		elif (LayerMask.NameToLayer("Bottom World") == gameObject.layer) and (LayerMask.NameToLayer("Bottom World") == target.layer) and (target.renderer.enabled):
			inSameWorld = true
		else:
			inSameWorld = false
		yDis = Mathf.Abs(target.transform.position.y-transform.position.y)
		xDis = target.transform.position.x-transform.position.x

		if Time.time > hitTime + 5.0:
			HIT = false

		if HIT:
			if (inSameWorld):
				SHOOTER=false
				SEEKING=true
			else:
				#hit and phased out
				SHOOTER=false
				SEEKING=false
				PATROL=true
		elif inSameWorld and (Mathf.Abs(xDis) <=shootDistance) and (yDis < 2) and ((xDis<0 and direction<0) or (xDis>0 and direction>0)):
			SHOOTER=true #close enough/facing right direction to shoot
			SEEKING=true 
			HIT = false
		elif inSameWorld and (Mathf.Abs(xDis) <=followDistance) and (yDis < 2) and ((xDis<0 and direction<0) or (xDis>0 and direction>0)):
			SEEKING=true #close enough/facing right direction to seek him
			HIT = false
		else:
			SHOOTER=false
			SEEKING=false
			PATROL=true
			HIT = false
		if (SEEKING):
			if direction > 0 and (target.transform.position.x < transform.position.x):
				direction = direction*-1
				transform.Rotate(0, 180*direction, 0)
			elif direction < 0 and (target.transform.position.x > transform.position.x):
				direction = direction*-1
				transform.Rotate(0, 180*direction, 0)

		if (Time.time-shootTime > 0.1): 
			lazer.SetActive(false)
		if (SHOOTER and Time.time-shootTime > 3): #shoot every 3 secs
			# --stun gun --
			pos as Vector3 = Vector3(transform.position.x,transform.position.y+1,transform.position.z)
			shootDir = Vector3(direction,0,0)
			layerMask = 1 << gameObject.layer #filter ray to objects level only
			hitinfo as RaycastHit

			hitPlayer = Physics.Raycast (pos, shootDir, hitinfo, shootDistance, layerMask)

			#Audio.
			GameObject.Find("SoundEffects").GetComponent(SoundEffects).PlayZap(transform.position)

			#display gun's beam on screen (TODO: Designers can make this prettier...)
			lazer.transform.position = pos
			lazer.GetComponent(LineRenderer).SetPosition(0, lazer.transform.position)
			if direction < 0: 
				lazerEndXPos = lazer.transform.position.x - shootDistance

				if hitPlayer and hitinfo.transform.position.x > lazerEndXPos:
					lazerEndXPos = hitinfo.transform.position.x
			else: 
				lazerEndXPos = lazer.transform.position.x + shootDistance
				if hitPlayer and hitinfo.transform.position.x < lazerEndXPos:
					lazerEndXPos = hitinfo.transform.position.x

			lazerEndPos = Vector3(lazerEndXPos, lazer.transform.position.y,lazer.transform.position.z)
			lazer.GetComponent(LineRenderer).SetPosition(1, lazerEndPos)
			lazer.SetActive(true)
			PATROL=false

			shootTime = Time.time
			if hitPlayer and hitinfo.transform.name == target.name: #hit player, so stun them
				player1 as GameObject = GameObject.Find("Player1")
				player1.GetComponent[of Player]().stunPlayer(target)
				Camera.main.GetComponent(CameraPlay).Shake(0.5)
				HIT = true
				hitTime = Time.time
		elif (SEEKING and Time.time-shootTime > 0.1): #move towards player
			lazer.SetActive(false)
			if(Vector3.Distance( transform.position, target.transform.position)<followDistance): 
				#close enough to "see", so try to collect
				rigidbody.velocity.x = speed * direction

		rayDir as Vector3 = direction*Vector3.right
		hitObjectHigh as RaycastHit
		hitObjectMid as RaycastHit
		hitObjectLow as RaycastHit
		layerMask = 1 << gameObject.layer #filter ray to objects level only
		highPos = Vector3(transform.position.x,transform.position.y+2.8,transform.position.z)
		midPos = Vector3(transform.position.x,transform.position.y+1.5,transform.position.z)
		lowPos = Vector3(transform.position.x,transform.position.y+0.3,transform.position.z)
		hitSomething = Physics.Raycast (highPos, rayDir, hitObjectHigh, shootDistance/3,layerMask)
		hitSomethingMid = Physics.Raycast (midPos, rayDir, hitObjectMid, shootDistance/3,layerMask)
		hitSomethingLow = Physics.Raycast (lowPos, rayDir, hitObjectLow, shootDistance/3, layerMask)

		# if hit something high other than player, change directions
		highHitName =  (hitObjectHigh.rigidbody and hitObjectHigh.rigidbody.name) or ""
		midHitName =  (hitObjectMid.rigidbody and hitObjectMid.rigidbody.name) or ""
		lowHitName =  (hitObjectMid.rigidbody and hitObjectMid.rigidbody.name) or ""

		if target.name in [highHitName,midHitName,lowHitName]:
			rigidbody.velocity.x = 0
		elif (hitSomething or hitSomethingMid ) : 
			direction = direction*-1
			transform.Rotate(0, 180*direction, 0)

		# if hit low object, jump
		elif hitSomethingLow and lowHitName!=target.name: 
			rigidbody.velocity.y = 6.0

		if PATROL:
			rigidbody.velocity.x = speed * direction