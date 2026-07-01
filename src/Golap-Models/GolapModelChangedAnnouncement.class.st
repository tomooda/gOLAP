Class {
	#name : 'GolapModelChangedAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'golapModel'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapModelChangedAnnouncement class >> on: aGolapModel [

	^ self new
		  golapModel: aGolapModel;
		  yourself
]

{ #category : 'accessing' }
GolapModelChangedAnnouncement >> golapModel [

	^ golapModel
]

{ #category : 'accessing' }
GolapModelChangedAnnouncement >> golapModel: aGolapModel [

	golapModel := aGolapModel
]
