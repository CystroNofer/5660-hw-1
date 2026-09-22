import {vec3} from 'gl-matrix';
import Stats from 'stats-js';
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

import lambertVertSource from './shaders/lambert-vert.glsl?raw';
import lambertFragSource from './shaders/lambert-frag.glsl?raw';
import bgVertSource from './shaders/bg-vert.glsl?raw';
import bgFragSource from './shaders/bg-frag.glsl?raw';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 8,
  timeSpeed: 2.5,
  tailLength: 4,
  radialNoiseStrength: 0.05,
  radialNoiseVariance: 0.45,
  polarNoiseStrength: 0.1,
  polarNoiseVariance: 0.3,
  'Load Scene': loadScene, // A function pointer, essentially
  'Reset Controls': resetControls,
};

const defaultControls = {...controls};

let icosphere: Icosphere;
let square: Square;
let prevTesselations: number = 5;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
}

function resetControls() {
  Object.assign(controls, defaultControls);
}

const startTime = performance.now();

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'timeSpeed', 0, 10).step(0.5);
  gui.add(controls, 'tailLength', 0, 10).step(0.1);
  gui.add(controls, 'radialNoiseStrength', 0, 0.5).step(0.05);
  gui.add(controls, 'radialNoiseVariance', 0, 0.5).step(0.05);
  gui.add(controls, 'polarNoiseStrength', 0, 0.5).step(0.05);
  gui.add(controls, 'polarNoiseVariance', 0, 0.5).step(0.01);
  gui.add(controls, 'Load Scene');
  gui.add(controls, 'Reset Controls');

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, lambertVertSource),
    new Shader(gl.FRAGMENT_SHADER, lambertFragSource),
  ]);
  const bg = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, bgVertSource),
    new Shader(gl.FRAGMENT_SHADER, bgFragSource),
  ]);

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }
    lambert.setTime((performance.now() - startTime) / 1000 * controls.timeSpeed); // In seconds
    lambert.setTailLength(controls.tailLength);
    lambert.setNoiseParameters(controls.radialNoiseStrength, controls.radialNoiseVariance, controls.polarNoiseStrength, controls.polarNoiseVariance);
    bg.setTailLength(controls.tailLength);
    renderer.render(camera, bg, [
      square
    ]);
    renderer.render(camera, lambert, [
      icosphere
    ]);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
