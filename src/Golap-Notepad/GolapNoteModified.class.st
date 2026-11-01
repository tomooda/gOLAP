Class {
	#name : 'GolapNoteModified',
	#superclass : 'Announcement',
	#instVars : [
		'note'
	],
	#category : 'Golap-Notepad-Core',
	#package : 'Golap-Notepad',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GolapNoteModified class >> on: aGolapNote [

	^ self new
		  note: aGolapNote;
		  yourself
]

{ #category : 'accessing' }
GolapNoteModified >> note [

	^ note
]

{ #category : 'accessing' }
GolapNoteModified >> note: aGolapNote [

	note := aGolapNote
]
