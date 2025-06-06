import React, {
  MutableRefObject,
  ReactNode,
  useCallback,
  useEffect,
  useRef,
} from "react";
import { PageName } from "../context/page-context";
import { RecordPathDetails } from "../context/record-context";
import { getKey, KeyboardShortcut, keyboardShortcutHandler } from "../utils";
import AdminLink from "./AdminLink";

/**
 * React hook to add a global keyboard shortcut for the given
 * key for the lifetime of the component.
 */
function useKeyboardShortcut(
  key: KeyboardShortcut,
  action: (ev: KeyboardEvent) => void
): void {
  useEffect(() => {
    const handler = keyboardShortcutHandler(key, action);
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [key, action]);
}

/**
 * Add a global keyboard shortcut for the given key and simulate
 * a click on the ref'ed element.
 */
function useKeyboardShortcutRef<T extends HTMLElement>(
  key: KeyboardShortcut
): MutableRefObject<T | null> {
  const el = useRef<T | null>(null);
  const handler = useCallback(() => {
    el.current?.click();
  }, []);
  useKeyboardShortcut(key, handler);
  return el;
}

export default function AdminLinkWithHotkey({
  children,
  shortcut,
  ...linkProps
}: RecordPathDetails & {
  page: PageName;
  children: ReactNode;
  shortcut: KeyboardShortcut;
}): JSX.Element {
  const el = useKeyboardShortcutRef<HTMLAnchorElement>(shortcut);

  return (
    <AdminLink {...linkProps} title={getKey(shortcut)} ref={el}>
      {children}
    </AdminLink>
  );
}
