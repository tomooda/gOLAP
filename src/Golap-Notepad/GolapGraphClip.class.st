Class {
	#name : 'GolapGraphClip',
	#superclass : 'GolapClip',
	#category : 'Golap-Notepad-Clip',
	#package : 'Golap-Notepad',
	#tag : 'Clip'
}

{ #category : 'accessing' }
GolapGraphClip class >> kind [

	^ 'graph'
]

{ #category : 'operations' }
GolapGraphClip >> open [

	^ (Golap fromJSON: json) open
]
