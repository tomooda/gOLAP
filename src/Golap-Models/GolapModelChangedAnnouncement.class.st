Class {
	#name : 'GolapModelChangedAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'golapModel'
	],
	#category : 'Golap-Models-Announcement',
	#package : 'Golap-Models',
	#tag : 'Announcement'
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
