#!/bin/bash
export FCS_PATH="$HOME/fc-solve-bakers-game-range"
export FCS_MAX_DEAL_IDX="10000" FCS_PRESET_CONFIG="-g bakers_game" 
export FCS_MIN_DEAL_IDX="1" 
export FCS_DEALS_PER_BATCH="1000"
export FCS_NUM_SOLVERS="1" FCS_NUM_VERIFIERS="3"
