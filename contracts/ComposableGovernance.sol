// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {IMetadataRenderer} from "./interfaces/IMetadataRenderer.sol";

//JUST A "SKETCH", IMPROVE LATER.
contract ComposableGovernance is ERC721, ReentrancyGuard, Ownable {

  uint256 private _beliefId;
  IMetadataRenderer public renderer;


  struct Belief {
    address creator;
    string text;
    uint256 numberOfClones;
    bool isClone;
  }


  mapping(address owner => uint256 beliefId) private _ownerToBeliefId;
  mapping(uint256 beliefId => Belief) private _beliefIdToBelief;


  event ClonedBelief(
    address indexed clonedFrom, 
    address indexed clonedBy, 
    uint256 beliefCloned
  );

  event CreatedBelief(
    address indexed createdBy,
    uint256 beliefId
  );

  error NonexistentToken();


  constructor() ERC721("ComposableGovernance", "CG") Ownable() {}


  function createBelief(string calldata beliefText) public returns (uint256) {

    // check if is nouns holder

    _mint(msg.sender, ++_beliefId);

    _ownerToBeliefId[msg.sender] = _beliefId;

    ///use sstore2 to store the text, is better.
    _beliefIdToBelief[_beliefId] = Belief({
      text: beliefText,
      numberOfClones: 0,
      creator: msg.sender,
      isClone: false
    });

    emit CreatedBelief({
      createdBy: msg.sender,
      beliefId: _beliefId
    });

    return _beliefId;

  }

  function cloneBelief(uint256 beliefIdToClone) public returns (uint256) {
    if(_exists(beliefIdToClone)) {
      revert NonexistentToken();
    }

    _mint(msg.sender, ++_beliefId);

    _ownerToBeliefId[msg.sender] = _beliefId;
    _beliefIdToBelief[_beliefId] = Belief({
      text: _beliefIdToBelief[beliefIdToClone].text,
      numberOfClones: 0,
      creator: _beliefIdToBelief[beliefIdToClone].creator,
      isClone: true
    });

    _beliefIdToBelief[beliefIdToClone].numberOfClones += 1;

    emit ClonedBelief({
      clonedFrom: _beliefIdToBelief[beliefIdToClone].creator,
      clonedBy: msg.sender,
      beliefCloned: beliefIdToClone
    });

  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {

    if(!_exists(tokenId)) {
      revert NonexistentToken();
    }

    return renderer.tokenURI(tokenId);
  }

}
