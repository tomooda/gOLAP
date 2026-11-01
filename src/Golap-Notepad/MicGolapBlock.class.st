Class {
	#name : 'MicGolapBlock',
	#superclass : 'MicScriptBlock',
	#category : 'Golap-Notepad-Microdown',
	#package : 'Golap-Notepad',
	#tag : 'Microdown'
}

{ #category : 'accessing' }
MicGolapBlock class >> tag [

	^ #gOLAP
]

{ #category : 'visiting' }
MicGolapBlock >> accept: aVisitor [
	aVisitor visitGolapClip: self 
]
