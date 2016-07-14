{-# LANGUAGE OverloadedStrings #-}
import           System.FilePath.Posix
import           Hakyll

main :: IO ()
main = hakyll $ do
  match "images/*" $ do
    route   idRoute
    compile copyFileCompiler

  match "static/*" $ do
    route   idRoute
    compile copyFileCompiler

  match "fonts/*" $ do
    route   idRoute
    compile copyFileCompiler

  match "posts/*" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
      >>= saveSnapshot "content"
      >>= loadAndApplyTemplate "templates/post.html"    postCtx
      >>= loadAndApplyTemplate "templates/default-en.html" postCtx
      >>= relativizeUrls

  match "index.md" $ do
    route $ setExtension "html"
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let indexCtx =
            listField "posts" postCtx (return posts) `mappend`
            constField "title" "Home"                `mappend`
            defaultContext

      getResourceBody
        >>= applyAsTemplate indexCtx
        >>= renderPandoc
        >>= loadAndApplyTemplate "templates/default-en.html" indexCtx
        >>= relativizeUrls

  match "templates/*" $ compile templateCompiler

  match "root/*" $ do
    route $ customRoute $ takeFileName . toFilePath
    compile copyFileCompiler

  create ["atom.xml"] $ do
    route idRoute
    compile $ do
      loadAllSnapshots "posts/*" "content"
        >>= fmap (take 10) . recentFirst
        >>= renderAtom feedConfiguration feedCtx


postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

feedCtx :: Context String
feedCtx =
    bodyField "description" `mappend`
    defaultContext


feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "mpsyco.github.io"
    , feedDescription = ""
    , feedAuthorName  = "Francis St-Amour"
    , feedAuthorEmail = ""
    , feedRoot        = "http://mpsyco.github.io"
    }
    
