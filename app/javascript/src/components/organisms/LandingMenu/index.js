import React from 'react';
import Link from 'next/link';

import styles from './landingMenu.module.scss';
import SocialButtons from 'src/components/atoms/Button/SocialButtons';
const { main, menuWrapper, loginText, socialIconWrapper } = styles;

const LandingMenu = ({isLoggedIn, profileMenuItem}) => (
  <>
    <div className={main}>
      <div className={menuWrapper}>
        <Link href="/landing_page/host">
          <a>Host a Challenge</a>
        </Link>
        <Link href="/challenges">
          <a>Challenges</a>
        </Link>
        <Link href="https://discourse.aicrowd.com/">
          <a>Forum</a>
        </Link>
        <Link href="https://blog.aicrowd.com/">
          <a>Blog</a>
        </Link>

        {isLoggedIn ? (profileMenuItem.map(item => {
            if(item.name === "Profile") {
              return <div className={loginText}><a href={item.link}>{item.name}</a></div>
            } else if(item.name === "Sign Out") {
              return <a data-method="delete" href={item.link}>{item.name}</a>
            }
            return <a href={item.link}>{item.name}</a>
        })) :
        (<>
          <div className={loginText}>
            <a href="/participants/sign_in">Log In</a>
          </div>
          <a href="/participants/sign_up">Signup</a>
        </>
        )}
        <div className={socialIconWrapper}>
          <SocialButtons socialType="facebook" iconType="outline" link="https://www.facebook.com/AIcrowdHQ/" />
          <SocialButtons socialType="twitter" iconType="outline" link="https://twitter.com/AIcrowdHQ" />
          <SocialButtons socialType="linkedin" iconType="outline" link="https://www.linkedin.com/company/aicrowd" />
          <SocialButtons
            socialType="youtube"
            iconType="outline"
            link="https://www.youtube.com/channel/UCUWbe23kxbwpaAP9AlzZQbQ"
          />
          <SocialButtons socialType="discord" iconType="outline" link="http://discord.com/invite/XEa56FP" />
        </div>
      </div>
    </div>
  </>
);

export default LandingMenu;