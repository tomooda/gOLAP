Class {
	#name : 'GolapQueryClip',
	#superclass : 'GolapClip',
	#category : 'Golap-Notepad-Clip',
	#package : 'Golap-Notepad',
	#tag : 'Clip'
}

{ #category : 'accessing' }
GolapQueryClip class >> kind [

	^ 'query'
]

{ #category : 'operations' }
GolapQueryClip >> open [

	^ (GolapNetworkClientPresenter fromJSON: json) open
]
