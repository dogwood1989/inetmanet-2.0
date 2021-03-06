//
// Copyright (C) 2003 Andras Varga; CTIE, Monash University, Australia
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, see <http://www.gnu.org/licenses/>.
//


cplusplus {{
#include "Ethernet.h"
#include "MACAddress.h"
#include "Ieee802Ctrl_m.h" // for enums
}}


class noncobject MACAddress;

class noncobject MessageId;

enum EtherType;

enum SAPCode;

//
// This class should never be instantiated by the models, only specific
// subclasses: EthernetJam, EtherIFG and submodules of ~EtherFrame.
//
packet EtherTraffic
{
}

//
// Represents jam on the Ethernet.
//
packet EtherJam extends EtherTraffic
{
    long abortedPkTreeID = 0;  // this field stores the packetTreeId of the aborted packet
}

//
// Represents a filled inter-frame gap in burst mode.
// Also used for calculating IFG times.
//
packet EtherIFG extends EtherTraffic
{
    bitLength = INTERFRAME_GAP_BITS;
}

//
// Common base class for classes representing Ethernet II and 802.3 frame types,
// containing their common header fields.
//
// This class should never be instantiated by the models, only specific
// subclasses: ~EthernetIIFrame, ~EtherFrameWithLLC and ~EtherFrameWithSNAP.
//
// Source and destination MAC address are stored in data members.
// Other Ethernet header fields include:
//  - preamble: not stored (only contributes to length)
//  - length: stored in cPacket byteLength; during tranmission, cPacket byteLength
//    includes pyhsical layer overhead and the frameByteLength field stores the
//    actual frame length
//  - payload: stored a encapsulated packet (cPacket::encapsulate())
//  - crc: represented by cPacket::hasBitError()
//
packet EtherFrame extends EtherTraffic
{
    MACAddress dest;
    MACAddress src;
    int frameByteLength;  // frame length without physical layer overhead (preamble, SFD, carrier extension); used by MAC layer
}


//
// Ethernet II headers contain a 16-bit ~EtherType to identify
// the encapsulated protocol.
//
// Header length: src(6)+dest(6)+etherType(2) = 14 bytes
//
packet EthernetIIFrame extends EtherFrame
{
    string displayString = "b=,,,#00ff00";		// Mod1. Enables display string modification.
    int etherType enum (EtherType);
}


//
// Ethernet frame with 802.3 LLC header.
//
// Header length: src(6)+dest(6)+length(2)+ssap(1)+dsap(1)+control(1) = 17 bytes
//
packet EtherFrameWithLLC extends EtherFrame
{
    int dsap;
    int ssap;
    int control;
}


//
// Ethernet frame with 802.3 LLC and SNAP headers.
//
// The ssap, dsap and control LLC fields are set to fixed values in the
// frame: 0xAA, 0xAA, 0x03.
//
// Header length: src(6)+dest(6)+length(2)+ssap(1)+dsap(1)+control(1)+
// orgCode(3)+localCode(2) = 22 bytes
//
packet EtherFrameWithSNAP extends EtherFrameWithLLC
{
    dsap = 0xAA;
    ssap = 0xAA;
    control = 0x03;
    int orgCode;   // organizationally unique identifier (OUI); 0 for protocols that have an EtherType (ARP, IPv4, IPv6, etc.)
    int localcode; // protocol identifier (PID); stores ~EtherType if orgCode is 0
}


//
// Ethernet frame used by the PAUSE protocol
//
packet EtherPauseFrame extends EtherFrame
{
    int pauseTime; // in 512 bit-time units
}

// Mod1
// Ethernet 802.1Q Tag. VLAN
//
//
packet Ethernet1QTag
{
    string displayString = "b=,,,#a5ffa5";
    int VID=0; // VID Outter VID tag.
}


// Mod1
// Ethernet 802.1ah header.
//
//
packet Ethernet1ahITag
{
    string displayString = "b=,,,#3ea53e";
    int ISid=0; // ISID
}
