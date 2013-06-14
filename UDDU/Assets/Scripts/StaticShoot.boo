import UnityEngine

class StaticShoot (MonoBehaviour): 
	public shootDistance as single = 5
	public lazer as GameObject
	public direction = 1 #change to negative one if faving left
	public target as GameObject

	#state variables
	private SHOOTER as bool =false
	private HIT as bool =false 

	private shootTime as single = 0
	private shootDir as Vector3 = Vector3(-1,0,0)
	private hitTime as single = 0



	def setHit(isHit as bool):
		HIT = isHit        

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
			else:
				#hit and phased out
				SHOOTER=false
		elif inSameWorld and (Mathf.Abs(xDis) <=shootDistance) and (yDis < 2) and ((xDis<0 and direction<0) or (xDis>0 and direction>0)):
			SHOOTER=true #close enough/facing right direction to shoot
			HIT = false
		else:
			SHOOTER=false
			HIT = false

		if (Time.time-shootTime > 0.1): 
			lazer.SetActive(false)
		if (SHOOTER and Time.time-shootTime > 3): #shoot every 3 secs
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

			shootTime = Time.time
			if hitPlayer and hitinfo.transform.name == target.name: #hit player, so stun them
				player1 as GameObject = GameObject.Find("Player1")
				player1.GetComponent[of Player]().stunPlayer(target)
				Camera.main.GetComponent(CameraPlay).Shake(0.5)
				HIT = true
				hitTime = Time.time
