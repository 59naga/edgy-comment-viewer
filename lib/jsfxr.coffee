# Dependencies
AudioContext= (window.AudioContext or window.webkitAudioContext)

class Sound
  constructor: (datauri)->
    @pcm= new AudioContext
    @decode datauri if datauri?

  decode: (datauri)->
    @buffer= null
    @autoplay= off

    binary= atob datauri.slice datauri.indexOf(',')+1

    arrayBuffer= new ArrayBuffer binary.length
    data= new Uint8Array arrayBuffer
    data[i]= binary.charCodeAt i for i in [0..binary.length]

    @pcm.decodeAudioData arrayBuffer,(buffer)=>
      @buffer= buffer
      @play() if @autoplay

  play: ->
    return if @coolTime?
    return @autoplay= on unless @buffer?

    source= @pcm.createBufferSource();
    source.buffer= @buffer
    source.connect @pcm.destination
    source.start 0

class Jsfxr extends Sound
  constructor: (params)->
    datauri= @generate params if params?
    super datauri

  regenerate: (params)->
    @decode @generate params
  generate: (params)->
    order= [
      'waveType'
      'attackTime'
      'sustainTime'
      'sustainPunch'
      'decayTime'
      'startFrequency'
      'minFrequency'
      'slide'
      'deltaSlide'
      'vibratoDepth'
      'vibratoSpeed'
      'changeAmount'
      'changeSpeed'
      'squareDuty'
      'dutySweep'
      'repeatSpeed'
      'phaserOffset'
      'phaserSweep'
      'lpFilterCutoff'
      'lpFilterCutoffSweep'
      'lpFilterResonance'
      'hpFilterCutoff'
      'hpFilterCutoffSweep'
      'masterVolume'
    ]

    values= []
    values.push params[name] for name in order

    window.jsfxr values

module.exports= Jsfxr