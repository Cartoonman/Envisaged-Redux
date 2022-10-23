# Release Process

1. Increment `VERSION` file
2. Update `CHANGELOG.md` with new tagged release and set URL's accordingly at the bottom of the file.
    * Also add documentation URL at top of the changelog based on expected domain in step 6 for the given tag.
3. Push changes and tag.
4. Create temporary Branch of same name as Tag.
5. On Vercel, go to Git -> Deploy Hooks to create temp hook. Enter hook URL and press enter to trigget deployment. Revoke afterwards.
6. On resultant deployment, the URL should be in the form "https://envisaged-redux-git-vXXX-cartoonman.vercel.app/" where XXX is vX.X.X.
