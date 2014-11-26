var renderer	= new THREE.WebGLRenderer();
var holder = jQuery('#nyan-holder');
holder.height(window.innerHeight - 200);
var container = jQuery('#nyan');
renderer.setSize( container.parent().innerWidth() - 50, container.parent().innerHeight() );
//	document.body.appendChild( renderer.domElement );
container[0].appendChild(renderer.domElement);


var updateFcts	= [];
var scene	= new THREE.Scene();
scene.fog = new THREE.FogExp2( 0x003366, 0.0095 );

var camera	= new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.01, 1000 );
camera.position.z = 30;

var pointLight = new THREE.PointLight( 0xFFFFFF );
pointLight.position.z = 1000;
scene.add(pointLight);

//////////////////////////////////////////////////////////////////////////////////
//		comment								//
//////////////////////////////////////////////////////////////////////////////////

var paused	= false;

var nyanCat	= new THREEx.NyanCat()
scene.add( nyanCat.container )
updateFcts.push(function(delta, now){
  if( paused )	return
  nyanCat.update(delta, now)
})

var sound	= new THREEx.NyanCatSound()
document.body.addEventListener('mousedown', function(){
  paused	= paused ? false : true
  sound.toggle()
})

var nyanStars	= new THREEx.NyanCatStars()
scene.add( nyanStars.container )
updateFcts.push(function(delta, now){
  if( paused )	return
  nyanStars.update(delta, now)
})

var nyanRainbow	= new THREEx.NyanCatRainbow()
scene.add( nyanRainbow.container )
updateFcts.push(function(delta, now){
  if( paused )	return
  nyanRainbow.update(delta, now)
})

//////////////////////////////////////////////////////////////////////////////////
//		Camera Controls							//
//////////////////////////////////////////////////////////////////////////////////
var mouse	= {x : 0, y : 0}
document.addEventListener('mousemove', function(event){
  mouse.x	= (event.clientX / window.innerWidth ) - 0.5
  mouse.y	= (event.clientY / window.innerHeight) - 0.5
}, false)
updateFcts.push(function(delta, now){
  camera.position.x += (mouse.x*500 - camera.position.x) * 0.01
  camera.position.y += (mouse.y*500 - camera.position.y) * 0.01
  camera.lookAt( scene.position )
})

//////////////////////////////////////////////////////////////////////////////////
//		render the scene						//
//////////////////////////////////////////////////////////////////////////////////
updateFcts.push(function(){
  renderer.render( scene, camera );
})

//////////////////////////////////////////////////////////////////////////////////
//		loop runner							//
//////////////////////////////////////////////////////////////////////////////////
var lastTimeMsec= null
requestAnimationFrame(function animate(nowMsec){
  // keep looping
  requestAnimationFrame( animate );
  // measure time
  lastTimeMsec	= lastTimeMsec || nowMsec-1000/60
  var deltaMsec	= Math.min(200, nowMsec - lastTimeMsec)
  lastTimeMsec	= nowMsec
  // call each update function
  updateFcts.forEach(function(updateFn){
    updateFn(deltaMsec/1000, nowMsec/1000)
  })
})
