# Enums
### chatCommunity <sub>\<int></sub>
###### The ID of each chat community.
| Index | Value |
| :-: | :-: |
| en | 01 |
| fr | 02 |
| ru | 03 |
| br | 04 |
| es | 05 |
| cn | 06 |
| tr | 07 |
| vk | 08 |
| pl | 09 |
| hu | 10 |
| nl | 11 |
| ro | 12 |
| id | 13 |
| de | 14 |
| e2 | 15 |
| ar | 16 |
| ph | 17 |
| lt | 18 |
| jp | 19 |
| ch | 20 |
| fi | 21 |
| cz | 22 |
| hr | 23 |
| sk | 24 |
| bg | 25 |
| lv | 26 |
| he | 27 |
| it | 28 |
| et | 29 |
| az | 30 |
| pt | 31 |

---
### community <sub>\<int></sub>
###### The ID of each community.
| Index | Value |
| :-: | :-: |
| en | 00 |
| fr | 01 |
| ru | 02 |
| br | 03 |
| es | 04 |
| cn | 05 |
| tr | 06 |
| vk | 07 |
| pl | 08 |
| hu | 09 |
| nl | 10 |
| ro | 11 |
| id | 12 |
| de | 13 |
| e2 | 14 |
| ar | 15 |
| ph | 16 |
| lt | 17 |
| jp | 18 |
| ch | 19 |
| fi | 20 |
| cz | 21 |
| sk | 22 |
| hr | 23 |
| bg | 24 |
| lv | 25 |
| he | 26 |
| it | 27 |
| et | 29 |
| az | 30 |
| pt | 31 |

---
### emote <sub>\<int></sub>
###### The available emote ids.
| Index | Value |
| :-: | :-: |
| dance | 00 |
| laugh | 01 |
| cry | 02 |
| kiss | 03 |
| angry | 04 |
| clap | 05 |
| sleep | 06 |
| facepaw | 07 |
| sit | 08 |
| confetti | 09 |
| flag | 10 |
| marshmallow | 11 |
| selfie | 12 |
| highfive | 13 |
| highfive_1 | 14 |
| highfive_2 | 15 |
| partyhorn | 16 |
| hug | 17 |
| hug_1 | 18 |
| hug_2 | 19 |
| jigglypuff | 20 |
| kissing | 21 |
| kissing_1 | 22 |
| kissing_2 | 23 |
| carnaval | 24 |
| rockpaperscissors | 25 |
| rockpaperscissors_1 | 26 |
| rockpaperscissor_2 | 27 |

---
### emoticon <sub>\<int></sub>
###### The available emoticon ids.
| Index | Value |
| :-: | :-: |
| smiley | 0 |
| sad | 1 |
| tongue | 2 |
| angry | 3 |
| :D | 4 |
| shades | 5 |
| blush | 6 |
| sweatdrop | 7 |
| derp | 8 |
| OMG | 9 |

---
### gender <sub>\<int></sub>
###### The profile gender id.
| Index | Value |
| :-: | :-: |
| none | 0 |
| female | 1 |
| male | 2 |

---
### identifier <sub>\<table></sub>
###### The action identifiers (C_CC, Tribulle, ...) for packets.
| Index | Value |
| :-: | :-: |
| bulle | { 44, 01 } |
| message | { 60, 03 } |
| command | { 06, 26 } |
| community | { 08, 02 } |
| correctVersion | { 26, 03 } |
| heartbeat | { 26, 26 } |
| initialize | { 28, 01 } |
| joinTribeHouse | { 16, 01 } |
| login | { 26, 08 } |
| loadLua | { 29, 01 } |
| os | { 28, 17 } |
| packetOffset | { 44, 22 } |
| room | { 05, 38 } |
| roomMessage | { 06, 06 } |

---
### role <sub>\<int></sub>
###### The id for staff role identifiers.
| Index | Value |
| :-: | :-: |
| normal | 00 |
| moderator | 05 |
| administrator | 10 |
| mapcrew | 11 |
| funcorp | 13 |

---
### setting <sub>\<table></sub>
###### Miscellaneous connection settings.
| Index | Value |
| :-: | :-: |
| port | { 5555, 44444, 3724, 44440, 6112, 443 } |

---
### whisperState <sub>\<int></sub>
###### Possible states for the whisper.
| Index | Value |
| :-: | :-: |
| enabled | 1 |
| disabledPublic | 2 |
| disabledAll | 3 |

---