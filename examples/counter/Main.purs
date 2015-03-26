module Example.Counter where

import Data.Void
import Data.Tuple
import Data.Either

import Control.Monad.Eff

import DOM

import Halogen
import Halogen.Signal

import qualified Halogen.HTML as H
import qualified Halogen.HTML.Attributes as A
import qualified Halogen.HTML.Events as A

import qualified Halogen.Themes.Bootstrap3 as B

foreign import data Timer :: ! 

foreign import appendToBody
  "function appendToBody(node) {\
  \  return function() {\
  \    document.body.appendChild(node);\
  \  };\
  \}" :: forall eff. Node -> Eff (dom :: DOM | eff) Node
  
foreign import setInterval
  "function setInterval(n) {\
  \  return function(f) {\
  \    return function() {\
  \      window.setInterval(function() {\
  \        f();\
  \      }, n);\
  \    };\
  \  };\
  \}" :: forall eff a. Number -> Eff (timer :: Timer | eff) a -> Eff (timer :: Timer | eff) Node
  
-- | The state of the application
data State = State Number

-- | Inputs to the state machine
data Input = Tick

view :: forall p r node. (H.HTMLRepr node) => SF1 Input (node p r)
view = render <$> stateful (State 0) update
  where
  render :: State -> node p r
  render (State n) = 
    H.div (A.class_ B.container)
          [ H.h1 (A.id_ "header") [ H.text "counter" ]
          , H.p_ [ H.text (show n) ]
          ]
          
  update :: State -> Input -> State
  update (State n) Tick = State (n + 1)

main = do
  Tuple node driver <- runUI (pureUI view)
  appendToBody node
  setInterval 1000 $ driver Tick
  
